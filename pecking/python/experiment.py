from pecking.base import BaseOperant


class Experiment(BaseOperant):
    children = "sessions"

    num_sessions = property(fget=lambda x: len(x.sessions))

    def __init__(self, name= None, start=None, end=None, weight=None, fast_start=None):

        self.sessions = list()
        self.bird = None
        self.name = name
        self.start = start
        self.end = end
        self.fast_start = fast_start
        self.weight = weight

    def summary(self):

        columns = ["Start", "End", "Weight", "Sessions", "Blocks",
                   "Avg. Pecks", "Signficant Blocks"]
        if self.end is not None:
            end = self.end.strftime("%m/%d/%y")
        else:
            end = None
        values = [self.start.strftime("%m/%d/%y"),
                  end,
                  self.weight,
                  self.num_sessions, self.num_blocks,
                  self.total_pecks / float(self.num_blocks),
                  self.significant_blocks]

        return columns, values

    @property
    def num_blocks(self):

        num_blocks = 0
        for session in self.sessions:
            num_blocks += session.num_blocks

        return num_blocks

    @property
    def total_pecks(self):

        total_pecks = 0
        for session in self.sessions:
            total_pecks += session.total_pecks

        return total_pecks

    @property
    def significant_blocks(self):

        significant_blocks = 0
        for session in self.sessions:
            significant_blocks += session.significant_blocks

        return significant_blocks

    def show_weight(self, show_plot=True):

        weights = dict()
        if self.weight is not None:
            weights.setdefault("Time", list()).append(self.fast_start)
            weights.setdefault("Weight", list()).append(self.weight)
            weights.setdefault("Label", list()).append("Fast start")
            weights.setdefault("Pecks", list()).append(None)
            weights.setdefault("Num Reward", list()).append(None)
            weights.setdefault("Food Given", list()).append(None)

        for sess in self.sessions:
            if sess.start is not None:
                weights.setdefault("Time", list()).append(sess.start)
                weights.setdefault("Weight", list()).append(sess.weight)
                weights.setdefault("Label", list()).append("Session start")
                weights.setdefault("Pecks", list()).append(None)
                weights.setdefault("Num Reward", list()).append(None)
                weights.setdefault("Food Given", list()).append(None)

            if sess.end is not None:
                weights.setdefault("Time", list()).append(sess.end)
                weights.setdefault("Weight", list()).append(sess.post_weight)
                weights.setdefault("Label", list()).append("Session end")
                weights.setdefault("Pecks", list()).append(sess.total_pecks)
                weights.setdefault("Num Reward", list()).append(sess.total_reward)
                weights.setdefault("Food Given", list()).append(sess.seed_given)

        return weights

        index = weights.pop("Time")
        df = pd.DataFrame(weights, index=index)
        df["Weight"][df["Weight"] == 0] = None
        if show_plot:
            ts = df["Weight"]
            ts.index = df.index.format(formatter=lambda x: x.strftime("%m/%d"))
            ax = ts.plot(rot=0)
            ax.set_xticks(range(len(ts)))
            ax.set_xticklabels(ts.index)
            ax.set_ylabel("Weight")
            ax.set_xlabel("Date")

            ax2 = ax.twinx()
            ts = df["Pecks"][~np.isnan(df["Pecks"])]
            ts.index = df.index.format(formatter=lambda x: x.strftime("%m/%d"))
            ts.plot(rot=0, ax=ax2)


        return df
