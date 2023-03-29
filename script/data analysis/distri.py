import os
import re
from collections import defaultdict
import collections
import matplotlib.pyplot as plt
import pdb
import sys


benchmark = sys.argv[1]
p = sys.argv[2]

result_path = os.getcwd()
filename = result_path + "/../x86/parsec-3.0/" + benchmark + \
                         "/m5out/" + p + "p/simout"

starter = "**** REAL SIMULATION ****\n"
start = False

cpu_step = defaultdict(list)
cpu_walk = defaultdict(list)
cache_walk = []


class Step:
    def __init__(self, level, timestamp, va, nextRead, iord):
        self.level = level
        self.timestamp = int(timestamp)
        self.va = va
        self.nextRead = nextRead
        self.iord = iord

    def __repr__(self):
        return '{' + self.level + ', ' + str(self.timestamp) + ', ' + \
                     self.va + ', ' + self.nextRead + ', ' + self.iord + '} \n'


class Walk:
    def __init__(self, step1, step2, step3, step4, thp):
        self.step1 = step1
        self.step2 = step2
        self.step3 = step3
        self.step4 = step4
        self.thp = thp

    def __repr__(self):
        return '{**start THP:' + str(self.thp) + " \n->" + \
                     repr(self.step1) + "->" + \
                     repr(self.step2) + "->" + \
                     repr(self.step3) + "->" + \
                     repr(self.step4) + "Fin**" + '}'

    def cumu_delay(self):
        if self.thp == 0:
            return float(self.step4.timestamp - self.step1.timestamp)/500
        else:
            return float(self.step3.timestamp - self.step1.timestamp)/500

    def demap(self):
        return [self.step1.nextRead, self.step2.nextRead, self.step3.nextRead, self.step4.nextRead]


class CacheStep:
    def __init__(self, timestamp, name, pa):
        self.timestamp = int(timestamp)
        self.name = name
        self.pa = int(pa, 0)

    def __repr__(self):
        return '{' + str(self.timestamp) + ', ' + \
                       self.name + ', ' + hex(self.pa) + '} \n'


for line in open(filename):

    if starter != line:
        if start is False:
            continue
    else:
        start = True
        continue

    if start is True:
        line_element = re.split(":|\ |\.|\,", line)
        if 'cpu' in line:
            if 'LongPD' in line_element:
                step = Step(line_element[8], line_element[0],
                            line_element[11], line_element[13],
                            line_element[5])
                cpu_step[line_element[3]].append(step)
            else:
                step = Step(line_element[8], line_element[0],
                            line_element[10], line_element[12],
                            line_element[5])
                cpu_step[line_element[3]].append(step)
        elif 'ruby' in line:
            if 'l1_cntrl' in line:
                cache_step = CacheStep(line_element[0],
                                       line_element[8] + ':' + line_element[4],
                                       line_element[10])
            elif 'l2_cntrl' in line:
                cache_step = CacheStep(line_element[0],
                                       line_element[4],
                                       line_element[10])
            else:

                print("wrong controller type")
                exit(-1)
            cache_walk.append(cache_step)
        elif 'Exiting' in line:
            break
        else:
            print(line)
            print('wrong line')
            exit(-1)

# print(cache_walk)

for cpu in cpu_step.keys():
    for index, step in enumerate(cpu_step[cpu]):
        if step.level == "LongPML4":
            step1 = cpu_step[cpu][index]
            step2 = cpu_step[cpu][index+1]
            step3 = cpu_step[cpu][index+2]
            if index+3 < len(cpu_step[cpu]):
                if "LongPTE" in cpu_step[cpu][index+3].level:
                    step4 = cpu_step[cpu][index+3]
                    thp = 0
                else:
                    step4 = Step("nan", 0, "nan", "nan", "nan")
                    thp = 1
            walk = Walk(step1, step2, step3, step4, thp)
            cpu_walk[cpu].append(walk)
        else:
            continue

############################################
# now enter the data drawing world

results_dir = '../../m5out/x86/parsec-3.0/' + benchmark + '/' + p + 'p/'

if not os.path.isdir(results_dir):
    os.makedirs(results_dir)

############################################
# 1. Delay histogram


def histogram():

    histo_array = []

    for cpu in cpu_walk.keys():
        for walk in cpu_walk[cpu]:
            delay = walk.cumu_delay()
            if(delay < 10000):
                # filtering out the huge delays caused
                # by squashing/TLB shutdown
                histo_array.append(delay)

    plt.rcParams.update({'figure.figsize': (7, 5), 'figure.dpi': 100})
    plt.hist(histo_array, bins=50, range=(0, max(histo_array)))
    plt.gca().set(title='Frequency Histogram', ylabel='Frequency')
    plt.savefig(results_dir + 'histogram.svg')
    plt.show()

############################################
# 2. Delay across time


def delay_cross_time(pshow):
    delay_array = defaultdict(list)
    time_array = defaultdict(list)
    show = pshow

    for cpu in cpu_walk.keys():
        for walk in cpu_walk[cpu]:
            if show == "both":
                delay = walk.cumu_delay()
                if(delay < 10000):
                    delay_array[cpu].append(delay)
                    time_array[cpu].append(walk.step1.timestamp)
            elif show == "itb":
                if (walk.step1.iord == 'itb'):
                    delay = walk.cumu_delay()
                    if(delay < 10000):
                        delay_array[cpu].append(delay)
                        time_array[cpu].append(walk.step1.timestamp)
                else:
                    continue
            elif show == "dtb":
                if (walk.step1.iord == 'dtb'):
                    delay = walk.cumu_delay()
                    if(delay < 10000):
                        delay_array[cpu].append(delay)
                        time_array[cpu].append(walk.step1.timestamp)
                else:
                    continue
            else:
                print("keyword 'show' wrong")
                exit(-2)

        plt.plot([t/500/1000/1000/1000 for t in time_array[cpu]],
                 delay_array[cpu], 'o')

    plt.ylim([0, 600])
    plt.rcParams.update({'figure.figsize': (7, 5), 'figure.dpi': 100})
    plt.gca().set(title='VAT delay with exe. time', ylabel='Delay')
    plt.savefig(results_dir + 'delay_cross_time.svg')
    plt.show()

############################################
# 3. Page walk distribution


def page_table_distri():
    histo_set = defaultdict(int)

    for step in cache_walk:
        # print(step)
        histo_set[step.name] = histo_set[step.name] + 1

    histo_set = collections.OrderedDict(sorted(histo_set.items()))

    num_l1 = (sum("l1_cntrl" in p for p in histo_set.keys()))

    for i in range(int(num_l1/2)):
        to_l1 = list(histo_set.keys())[i]
        from_l1 = list(histo_set.keys())[i+int(num_l1/2)]
        histo_set[from_l1] = histo_set[to_l1] - histo_set[from_l1]

    plt.bar(histo_set.keys(), histo_set.values())

    plt.rcParams.update({'figure.figsize': (7, 5), 'figure.dpi': 100})
    plt.xticks(rotation=45)
    plt.gca().set(title='Frequency Histogram', ylabel='Frequency')
    plt.savefig(results_dir + 'page_walk_distribution.svg')
    plt.show()


if __name__ == '__main__':
    histogram()
    delay_cross_time('itb')
    page_table_distri()
