import os, re
import pandas as pd
import numpy as np
from pecking import bird, block, experiment, session

def get_files_by_bird(directory):

    def get_files(directory):
        for fname in os.listdir(directory):
            fullname = os.path.join(directory, fname)
            if os.path.isdir(fullname):
                get_files(fullname)
            else:
                m = parse_filename(fname)
                if (m is not None) and (len(m) == 1):
                    files.setdefault(m[0], list()).append(os.path.join(directory, fname))

    files = dict()
    get_files(directory)

    return files

def parse_filename(fname):

    fname = fname.lower()
    if not fname.endswith("timestamp.txt"):
        return

    file_format = "[A-Za-z]{2,6}[0-9]{2,4}"
    m = re.findall(file_format, fname)

    return m

def get_experiment_files(files):

    # Get the timestamp dates to determine when a new experiment is run
    # Experiments are chunks of sessions separated by no more than a day (hackey, I know)
    dates = [re.findall("([0-9\s]{6})", os.path.basename(fname))[0] for fname in files]
    dates = [pd.to_datetime(date.replace(" ", "0"), format="%y%m%d") for date in dates]
    ser = pd.Series(dates)
    ser.sort()
    start = 0
    inds = np.where(ser.diff() > np.timedelta64(1, 'D'))[0]
    if len(inds):
        for ind in np.hstack([inds, len(ser)]):
            date_slice = ser.iloc[start: ind]
            yield ([files[ii] for ii in date_slice.index], date_slice)
            start = ind

def get_session_files(files):

    datetimes = ["".join(re.findall("([0-9\s]{6})", os.path.basename(fname))) for fname in files]
    datetimes = [pd.to_datetime(dt.replace(" ", "0"), format="%y%m%d%H%M%S") for dt in datetimes]
    ser = pd.Series(datetimes)
    ser.sort()
    days = [ts.day for ts in ser]
    ind = 0
    new_ind = len(days)
    while (ind < len(days)):
        day = days[ind]
        for ii, dd in enumerate(days[ind:]):
            if dd != day:
                new_ind = ind + ii
                break
            if ind + ii + 1 == len(days):
                new_ind = len(days)

        yield files[ind: new_ind], ser.iloc[ind: new_ind]
        ind = new_ind

def get_block_data(fname, start=pd.datetime(2000, 01, 01)):

    data_labels = ["time", "class", "number"]
    try:
        init_data = pd.read_csv(fname,
                                delimiter="\t",
                                header=0,
                                names=data_labels)
    except pd.parser.CParserError:
        return

    datetimes = map(lambda x: pd.datetools.timedelta(seconds=float(x)) + start, init_data["time"])
    timeseries = dict()
    timeseries["class"] = pd.Series(map(lambda x: int(x == "GoStim"), init_data["class"]),
                                    index=datetimes,
                                    name="class")
    timeseries["number"] = pd.Series(map(int, init_data["number"]),
                                     index=datetimes,
                                     name="number")
    return pd.DataFrame(timeseries)


def parse_time_file(fname):

    with open(fname, "r") as f:
        contents = f.read()
    return re.findall("\d{,2}\:\d{,2}\:\d{,2}", contents)

if __name__ == "__main__":

    # First get a dictionary with all of the TimeStamp files with the bird name as the key
    directory = "/Users/tylerlee/pecking_data"
    filenames = get_files_by_bird(directory)

    # Loop through the dictionary and import each bird
    birds = dict()
    for bird_name, files in filenames.iteritems():
        b = bird.Bird(bird_name)
        for exp_files, datestamps in get_experiment_files(files):
            e = experiment.Experiment(start=datestamps.iat[0], end=datestamps.iat[-1])
            for session_files, timestamps in get_session_files(exp_files):
                sess = session.Session(timestamps.iat[0].date())
                for ii, (ts, fname) in enumerate(zip(timestamps, session_files)):
                    time_file = fname.replace("TimeStamp.txt", "parameters.txt")
                    blk_times = [pd.to_datetime("/".join([ts.date().isoformat(), bt]), format="%Y-%m-%d/%H:%M:%S") for bt in parse_time_file(time_file)]
                    if len(blk_times) == 2:
                        blk = block.Block(fname, blk_times[0], blk_times[1])
                        blk.data = get_block_data(fname, blk_times[0].to_datetime())
                    elif len(blk_times) == 3:
                        blk = block.Block(fname, blk_times[0], blk_times[2], blk_times[1])
                        blk.data = get_block_data(fname, blk_times[1].to_datetime())
                    else:
                        continue
                    if (blk.data is not None) and (len(blk.data)):
                        blk.compute_statistics()
                        blk.session = sess
                        sess.blocks.append(blk)

                if sess.num_blocks > 0:
                    sess.experiment = exp
                    e.sessions.append(sess)

            if e.num_sessions > 0:
                e.bird = b
                b.experiments.append(e)

        if b.num_experiments > 0:
            birds[bird_name] = b






