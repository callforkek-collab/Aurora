"""Minimal GFF V3.2 writer/reader (BioWare Generic File Format, Aurora engine).

A GFF file is a tree of structs. Every field has a type, a label (max 16
chars) and a value. The top-level struct always has index 0 and type
0xFFFFFFFF.
"""

import struct as _st

# Field type ids
BYTE, CHAR, WORD, SHORT, DWORD, INT, DWORD64, INT64 = 0, 1, 2, 3, 4, 5, 6, 7
FLOAT, DOUBLE, CEXOSTRING, RESREF, CEXOLOCSTRING, VOID, STRUCT, LIST = (
    8, 9, 10, 11, 12, 13, 14, 15)

_SIMPLE_FMT = {BYTE: "<B", CHAR: "<b", WORD: "<H", SHORT: "<h",
               DWORD: "<I", INT: "<i", FLOAT: "<f"}
_COMPLEX_FMT = {DWORD64: "<Q", INT64: "<q", DOUBLE: "<d"}

TYPE_NAMES = {
    BYTE: "byte", CHAR: "char", WORD: "word", SHORT: "short", DWORD: "dword",
    INT: "int", DWORD64: "dword64", INT64: "int64", FLOAT: "float",
    DOUBLE: "double", CEXOSTRING: "cexostring", RESREF: "resref",
    CEXOLOCSTRING: "cexolocstring", VOID: "void", STRUCT: "struct", LIST: "list",
}

# Text encoding used for CExoString / CExoLocString contents. NWN has no
# Unicode support: Russian localisations use cp1251, western ones cp1252.
ENCODING = "cp1251"


class LocString:
    """CExoLocString: a TLK string reference plus inline per-language strings.

    `strings` maps StringID (= language_id * 2 + gender) to text.
    """

    def __init__(self, strings=None, strref=0xFFFFFFFF):
        self.strref = strref
        self.strings = dict(strings or {})

    def __repr__(self):
        return f"LocString({self.strings!r}, strref={self.strref:#x})"


class Struct:
    def __init__(self, struct_type=0, fields=None):
        self.type = struct_type
        # list of (label, field_type, value); order is preserved
        self.fields = list(fields or [])

    def add(self, label, field_type, value):
        if len(label) > 16:
            raise ValueError(f"GFF label too long: {label!r}")
        self.fields.append((label, field_type, value))
        return self

    def get(self, label, default=None):
        for lbl, _, val in self.fields:
            if lbl == label:
                return val
        return default

    def __repr__(self):
        return f"Struct({self.type}, {len(self.fields)} fields)"


def _encode(text):
    return text.encode(ENCODING)


class _Writer:
    def __init__(self):
        self.structs = []      # [type, data_or_offset, field_count]
        self.fields = []       # [type, label_index, data_or_offset]
        self.labels = []
        self.label_index = {}
        self.field_data = bytearray()
        self.field_indices = bytearray()
        self.list_indices = bytearray()

    def label(self, name):
        if name not in self.label_index:
            self.label_index[name] = len(self.labels)
            self.labels.append(name)
        return self.label_index[name]

    def add_struct(self, s):
        idx = len(self.structs)
        self.structs.append([s.type, 0xFFFFFFFF, len(s.fields)])
        field_ids = [self.add_field(lbl, ft, val) for lbl, ft, val in s.fields]
        if len(field_ids) == 1:
            self.structs[idx][1] = field_ids[0]
        elif len(field_ids) > 1:
            self.structs[idx][1] = len(self.field_indices)
            self.field_indices += _st.pack(f"<{len(field_ids)}I", *field_ids)
        return idx

    def add_field(self, label, ft, value):
        fidx = len(self.fields)
        entry = [ft, self.label(label), 0]
        self.fields.append(entry)

        if ft in _SIMPLE_FMT:
            raw = _st.pack(_SIMPLE_FMT[ft], value)
            entry[2] = int.from_bytes(raw.ljust(4, b"\0"), "little")
        elif ft == STRUCT:
            entry[2] = self.add_struct(value)
        elif ft == LIST:
            # Reserve the list slot first; child structs get indices as they
            # are written.
            offset = len(self.list_indices)
            self.list_indices += b"\0" * (4 + 4 * len(value))
            ids = [self.add_struct(child) for child in value]
            self.list_indices[offset:offset + 4 + 4 * len(ids)] = _st.pack(
                f"<I{len(ids)}I", len(ids), *ids)
            entry[2] = offset
        else:
            entry[2] = len(self.field_data)
            self.field_data += self.complex_data(ft, value)
        return fidx

    @staticmethod
    def complex_data(ft, value):
        if ft in _COMPLEX_FMT:
            return _st.pack(_COMPLEX_FMT[ft], value)
        if ft == CEXOSTRING:
            raw = _encode(value)
            return _st.pack("<I", len(raw)) + raw
        if ft == RESREF:
            raw = value.lower().encode("ascii")
            if len(raw) > 16:
                raise ValueError(f"ResRef too long: {value!r}")
            return _st.pack("<B", len(raw)) + raw
        if ft == CEXOLOCSTRING:
            body = _st.pack("<II", value.strref, len(value.strings))
            for sid, text in sorted(value.strings.items()):
                raw = _encode(text)
                body += _st.pack("<iI", sid, len(raw)) + raw
            return _st.pack("<I", len(body)) + body
        if ft == VOID:
            return _st.pack("<I", len(value)) + bytes(value)
        raise ValueError(f"Unsupported GFF field type {ft}")


def write_gff(root, file_type):
    """Serialise `root` (a Struct) to bytes. `file_type` is e.g. 'IFO '."""
    if len(file_type) != 4:
        raise ValueError("file_type must be 4 characters, e.g. 'ARE '")
    root.type = 0xFFFFFFFF
    w = _Writer()
    w.add_struct(root)

    struct_bytes = b"".join(_st.pack("<3I", *s) for s in w.structs)
    field_bytes = b"".join(_st.pack("<3I", *f) for f in w.fields)
    label_bytes = b"".join(l.encode("ascii").ljust(16, b"\0") for l in w.labels)

    header_size = 56
    offsets = []
    pos = header_size
    blocks = [(struct_bytes, len(w.structs)), (field_bytes, len(w.fields)),
              (label_bytes, len(w.labels)), (bytes(w.field_data), len(w.field_data)),
              (bytes(w.field_indices), len(w.field_indices)),
              (bytes(w.list_indices), len(w.list_indices))]
    for data, count in blocks:
        offsets += [pos, count]
        pos += len(data)

    header = file_type.encode("ascii") + b"V3.2" + _st.pack("<12I", *offsets)
    return header + b"".join(data for data, _ in blocks)


def read_gff(data):
    """Parse GFF bytes. Returns (file_type, root Struct)."""
    file_type = data[0:4].decode("ascii")
    version = data[4:8].decode("ascii")
    if version != "V3.2":
        raise ValueError(f"Unsupported GFF version {version!r}")
    (s_off, s_cnt, f_off, f_cnt, l_off, l_cnt, fd_off, fd_cnt,
     fi_off, fi_cnt, li_off, li_cnt) = _st.unpack_from("<12I", data, 8)

    labels = [data[l_off + i * 16:l_off + i * 16 + 16].rstrip(b"\0").decode("ascii")
              for i in range(l_cnt)]

    def read_field(i):
        ft, li, dat = _st.unpack_from("<3I", data, f_off + i * 12)
        raw4 = _st.pack("<I", dat)
        if ft in _SIMPLE_FMT:
            val = _st.unpack(_SIMPLE_FMT[ft], raw4[:_st.calcsize(_SIMPLE_FMT[ft])])[0]
        elif ft == STRUCT:
            val = read_struct(dat)
        elif ft == LIST:
            (n,) = _st.unpack_from("<I", data, li_off + dat)
            ids = _st.unpack_from(f"<{n}I", data, li_off + dat + 4)
            val = [read_struct(k) for k in ids]
        else:
            p = fd_off + dat
            if ft in _COMPLEX_FMT:
                val = _st.unpack_from(_COMPLEX_FMT[ft], data, p)[0]
            elif ft == CEXOSTRING:
                (n,) = _st.unpack_from("<I", data, p)
                val = data[p + 4:p + 4 + n].decode(ENCODING)
            elif ft == RESREF:
                n = data[p]
                val = data[p + 1:p + 1 + n].decode("ascii")
            elif ft == CEXOLOCSTRING:
                _total, strref, count = _st.unpack_from("<3I", data, p)
                q = p + 12
                strings = {}
                for _ in range(count):
                    sid, n = _st.unpack_from("<iI", data, q)
                    strings[sid] = data[q + 8:q + 8 + n].decode(ENCODING)
                    q += 8 + n
                val = LocString(strings, strref)
            elif ft == VOID:
                (n,) = _st.unpack_from("<I", data, p)
                val = data[p + 4:p + 4 + n]
            else:
                raise ValueError(f"Unknown field type {ft}")
        return labels[li], ft, val

    def read_struct(i):
        stype, dat, n = _st.unpack_from("<3I", data, s_off + i * 12)
        if n == 1:
            ids = [dat]
        elif n > 1:
            ids = _st.unpack_from(f"<{n}I", data, fi_off + dat)
        else:
            ids = []
        return Struct(stype, [read_field(k) for k in ids])

    return file_type, read_struct(0)


def dump(s, indent=0, out=None):
    """Human-readable dump of a Struct tree (for debugging)."""
    lines = out if out is not None else []
    pad = "  " * indent
    for label, ft, val in s.fields:
        if ft == STRUCT:
            lines.append(f"{pad}{label} <struct {val.type}>")
            dump(val, indent + 1, lines)
        elif ft == LIST:
            lines.append(f"{pad}{label} <list, {len(val)}>")
            for k, child in enumerate(val):
                lines.append(f"{pad}  [{k}] <struct {child.type}>")
                dump(child, indent + 2, lines)
        else:
            lines.append(f"{pad}{label} <{TYPE_NAMES[ft]}> = {val!r}")
    return lines if out is None else None
