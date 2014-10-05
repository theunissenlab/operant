from pecking.core.base import BaseOperant


class Block(self):

    date = property(fget=lambda x: x.session.date)

    def __init__(self):

        self.stimuli = list()
        self.num_trials = None
        self.time = None
        self.duration = None
        self.session = None

    def summary(self):

        columns = ["Time", "Duration", "Total Pecks", "Total No Re", "Total Re", "No Re Interrupts", "Re Interrupts"]
        values = [self.time, self.duration, self.total_pecks, self.total_no_reward, self.total_reward,
                  self.no_reward_interrupts, self.reward_interrupts]

        return columns, values
    


