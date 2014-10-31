from pecking.block import Block

class Importer(object):

    def parse(self, files):

        pass

class MatlabTxt(Importer):

    pattern = "(?P<name>(?:[a-z]{2,3})+(?:[0-9]{2})+[mf]?)_(?P<date>[\d\s]{6})_(?P<time>[\d\s]{6})_[^_]*_[^_]*_(?P<file>[a-z]+)\.txt"

    def __init__(self):

        self.files = list()
        self.blocks = list()


    def parse(self, files):

        block_groups = self.group_files(files)

        for file_grp in block_groups.values():
            files, mdicts = zip(*file_grp)
            blk = Block()
            blk.name = mdicts["name"]


            self.files.append(file_grp)


    def group_files(self, files):

        if isinstance(files, str):
            files = [files]

        block_groups = dict()
        for fname in files:
            if os.path.exists(fname):
                if os.path.isdir(fname):
                    block_groups.update(**self.group_files(map(lambda x: os.path.join(fname, x), os.listdir(fname))))
                else:
                    m = re.match(self.pattern, os.path.basename(fname))
                    if m is not None:
                        m = m.groupdict()
                    else:
                        print("File does not match regex pattern: %s" % fname)
                        continue
                    key = "%s_%s_%s" % (m["name"], m["date"], m["time"])
                    block_groups.setdefault(key, list()).append((fname, m))
            else:
                print("File does not exist! %s" % fname)
                continue

        return block_groups

    def same_block(pattern, file1, file2):

        m1 = re.match(pattern, file1, re.IGNORECASE)
        m2 = re.match(pattern, file2, re.IGNORECASE)
        if m1 is not None:
            m1 = m1.groupdict()
        else:
            print("File does not match regex pattern: %s" % file1)
            return False
        if m2 is not None:
            m2 = m2.groupdict()
        else:
            print("File does not match regex pattern: %s" % file2)
            return False
        if (m1["name"] == m2["name"]) and \
            (m1["date"] == m2["date"]) and \
            (m1["time"] == m2["time"]):
            return True
        else:
            return False


    def parse_filename(fname):

        fname = fname.lower()
        if not fname.endswith("timestamp.txt"):
            return

        file_format = "[A-Za-z]{2,6}[0-9]{2,4}"
        m = re.findall(file_format, fname)
        if m is not None:
            m = [bn for bn in m if not bn.lower().startswith("trial")]
            if len(m) == 1:
                return m[0]