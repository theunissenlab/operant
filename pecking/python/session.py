from pecking.core.base import BaseOperant


class Session(BaseOperant):

    children = ["blocks"]
    num_blocks = property(fget=lambda self: len(self.blocks))

    def __init__(self):

        self.blocks = list()
        self.annotations = dict()
        self.time = None
        self.date = None
        self.duration = None
        self.experiment = None
        self.weight = None
        self.box = None
        self.post_weight = None

    def summary(self):

        columns = ["Date", "Time", "Weight", "Box", "Total Pecks", "Significant blocks"]
        values = [self.date, self.time, self.weight, self.box, self.total_pecks, self.significant_blocks]

        return columns, values

    @property
    def total_pecks(self):

        total_pecks = 0
        for blk in self.blocks:
            total_pecks += blk.pecks

        return total_pecks

    @property
    def significant_blocks(self):

        significant_blocks = 0
        for blk in self.blocks:
            if blk.is_significant:
                significant_blocks += 1

        return significant_blocks