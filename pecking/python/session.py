from pecking.base import BaseOperant


class Session(BaseOperant):

    children = "blocks"
    num_blocks = property(fget=lambda self: len(self.blocks))

    def __init__(self, name=None,
                 start=None, end=None,
                 weight=None, post_weight=None,
                 box=None, seed_given=None,
                 notes=None, labels=None):

        self.name = name
        self.blocks = list()
        self.start = start
        self.end = end
        self.weight = weight
        self.box = box
        self.post_weight = post_weight
        self.seed_given = seed_given
        self.notes = notes
        self.labels = labels
        self.experiment = None

    def summary(self):

        columns = ["Start", "Initial Weight", "Final Weight",
                   "Stimulus Label", "Total Pecks", "# Blocks",
                   "Significant blocks"]
        values = [self.start.strftime("%m/%d/%y %H:%M:%S"),
                  self.weight,
                  self.post_weight,
                  self.labels,
                  self.total_pecks,
                  self.num_blocks,
                  self.significant_blocks]

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

    @property
    def weight_loss(self):

        if self.experiment is not None:
            if (self.weight is not None) and (self.experiment.weight is not None):
                return 100 * (1 - float(self.weight) / float(self.experiment.weight))
