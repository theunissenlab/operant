from pecking.base import BaseOperant


class Session(BaseOperant):

    children = "blocks"
    num_blocks = property(fget=lambda self: len(self.blocks))

    def __init__(self, date, start=None, end=None, weight=None, post_weight=None, box=None):

        self.blocks = list()
        self.date = date
        self.start = start
        self.end = end
        self.weight = weight
        self.box = box
        self.post_weight = post_weight
        self.experiment = None

    def summary(self):

        columns = ["Date", "Time", "Weight", "Box", "Total Pecks", "Significant blocks"]
        values = [self.date, self.start, self.weight, self.box, self.total_pecks, self.significant_blocks]

        return columns, values

    @property
    def total_pecks(self):

        total_pecks = 0
        for blk in self.blocks:
            total_pecks += blk.total_pecks

        return total_pecks

    @property
    def significant_blocks(self):

        significant_blocks = 0
        for blk in self.blocks:
            if blk.is_significant:
                significant_blocks += 1

        return significant_blocks