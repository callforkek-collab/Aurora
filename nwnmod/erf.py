"""ERF V1.0 archive writer/reader (.mod, .erf, .hak, .nwm)."""

import datetime
import struct as _st

# Resource type ids used by NWN 1.
RESTYPES = {
    "bmp": 1, "tga": 3, "wav": 4, "plt": 6, "ini": 7, "txt": 10,
    "mdl": 2002, "nss": 2009, "ncs": 2010, "are": 2012, "set": 2013,
    "ifo": 2014, "bic": 2015, "wok": 2016, "2da": 2017, "txi": 2022,
    "git": 2023, "uti": 2025, "utc": 2027, "dlg": 2029, "itp": 2030,
    "utt": 2032, "dds": 2033, "uts": 2035, "ltr": 2036, "gff": 2037,
    "fac": 2038, "ute": 2040, "utd": 2042, "utp": 2044, "dft": 2045,
    "gic": 2046, "gui": 2047, "utm": 2051, "dwk": 2052, "pwk": 2053,
    "jrl": 2056, "utw": 2058, "ssf": 2060, "ndb": 2064, "ptm": 2065,
    "ptt": 2066,
}
RESTYPE_EXT = {v: k for k, v in RESTYPES.items()}

HEADER_SIZE = 160
KEY_SIZE = 24
RES_SIZE = 8


def write_erf(resources, file_type="MOD ", description=None, build_date=None):
    """Build an ERF archive.

    `resources` is a list of (resref, ext, data). `description` is an optional
    {language_id: bytes} dict stored in the localized string table.
    """
    if len(file_type) != 4:
        raise ValueError("file_type must be 4 characters, e.g. 'MOD '")
    seen = set()
    for resref, ext, _ in resources:
        key = (resref.lower(), ext)
        if len(resref) > 16:
            raise ValueError(f"ResRef too long: {resref!r}")
        if key in seen:
            raise ValueError(f"Duplicate resource {resref}.{ext}")
        seen.add(key)

    description = description or {}
    loc = b"".join(_st.pack("<II", lang, len(text)) + text
                   for lang, text in sorted(description.items()))

    count = len(resources)
    off_loc = HEADER_SIZE
    off_keys = off_loc + len(loc)
    off_res = off_keys + count * KEY_SIZE
    off_data = off_res + count * RES_SIZE

    date = build_date or datetime.date.today()
    build_year = date.year - 1900
    build_day = date.timetuple().tm_yday - 1

    header = file_type.encode("ascii") + b"V1.0" + _st.pack(
        "<9I", len(description), len(loc), count, off_loc, off_keys, off_res,
        build_year, build_day, 0xFFFFFFFF)
    header = header.ljust(HEADER_SIZE, b"\0")

    keys = bytearray()
    table = bytearray()
    blob = bytearray()
    for res_id, (resref, ext, data) in enumerate(resources):
        keys += resref.lower().encode("ascii").ljust(16, b"\0")
        keys += _st.pack("<IHH", res_id, RESTYPES[ext], 0)
        table += _st.pack("<II", off_data + len(blob), len(data))
        blob += data

    return header + loc + bytes(keys) + bytes(table) + bytes(blob)


def read_erf(data):
    """Parse an ERF archive. Returns (file_type, [(resref, ext, bytes)])."""
    file_type = data[0:4].decode("ascii")
    version = data[4:8].decode("ascii")
    if version != "V1.0":
        raise ValueError(f"Unsupported ERF version {version!r}")
    (_lang_count, _loc_size, count, _off_loc, off_keys, off_res,
     _year, _day, _strref) = _st.unpack_from("<9I", data, 8)
    out = []
    for i in range(count):
        k = off_keys + i * KEY_SIZE
        resref = data[k:k + 16].rstrip(b"\0").decode("ascii")
        _res_id, restype, _ = _st.unpack_from("<IHH", data, k + 16)
        offset, size = _st.unpack_from("<II", data, off_res + i * RES_SIZE)
        out.append((resref, RESTYPE_EXT.get(restype, str(restype)),
                    data[offset:offset + size]))
    return file_type, out
