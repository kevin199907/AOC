# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
from .ema import EmaObserver
from .minmax import MinmaxObserver
from .omse import OmseObserver
from .percentile import PercentileObserver
from .ptf import PtfObserver
from .entropy import EntropyObserver

str2observer = {
    'minmax': MinmaxObserver,
    'entropy': EntropyObserver,
    'ema': EmaObserver,
    'omse': OmseObserver,
    'percentile': PercentileObserver,
    'ptf': PtfObserver
}


def build_observer(observer_str, module_type, bit_type, calibration_mode ,first=False):
    observer = str2observer[observer_str]
    return observer(module_type, bit_type, calibration_mode,first)
