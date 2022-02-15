import re
from distutils.version import StrictVersion

VERSION_RE = r'^(\d+)\.(\d+)(\.(\d+))?(\.?([ab]|dev)(\d+))?$'

def parse_version(vstring):
    version_re = re.compile(VERSION_RE, re.VERBOSE | re.ASCII)
    match = version_re.match(vstring)
    if not match:
        raise ValueError("invalid version number '%s'" % vstring)

    major, minor = tuple(map(int, match.group(1, 2)))

    if match.group(4):
        patch = int(match.group(4))
    else:
        patch = 0

    prerelease = match.group(6)
    
    if match.group(7):
        prerelease_num = int(match.group(7))
    else:
        prerelease_num = None

    return major, minor, patch, prerelease, prerelease_num


def construct_version(major, minor, patch, prerelease, prerelease_num):
    result = f"{major}.{minor}.{patch}"
    if prerelease:
        result += f".{prerelease}{prerelease_num}"
    return result

class StrictVersionExt(StrictVersion):
    """
        Modifeied to support 'dev' in prerelease
    """

    # version_re = re.compile(r'^(\d+) \. (\d+) (\. (\d+))? ([ab](\d+))?$',
    version_re = re.compile(VERSION_RE, re.VERBOSE | re.ASCII)


    def parse (self, vstring):
        major, minor, patch, prerelease, prerelease_num = parse_version(vstring)

        self.version = (major, minor, patch)

        if prerelease:
            self.prerelease = (prerelease, prerelease_num)
        else:
            self.prerelease = None
