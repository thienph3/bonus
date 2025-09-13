import os
import pandas as pd
import sys

from datetime import datetime, timedelta


def parse_number(number_str):
    if number_str is None or number_str == '':
        return None
    if pd.isna(number_str):
        return None
    return int(number_str)


def parse_date(date):
    if not date:
        return None

    if isinstance(date, pd.Timestamp):
        return date.date()

    if isinstance(date, datetime):
        return date.date()

    if isinstance(date, (float, int)):
        if date > 59:  # Excel bug: 1900 is not a leap year, so skip day 60
            date_offset = datetime(1899, 12, 30) + timedelta(days=int(date))
        else:
            date_offset = datetime(1899, 12, 31) + timedelta(days=int(date))
        return date_offset.date()

    date_str = str(date).strip()

    accepted_formats = [
        "%d/%m/%Y",
        "%Y-%m-%d",
        "%Y-%m-%d %H:%M:%S",
        "%d-%m-%Y",
        "%m/%d/%Y",
    ]

    for fmt in accepted_formats:
        try:
            return datetime.strptime(date_str, fmt).date()
        except ValueError:
            continue

    raise ValueError(
        f"Invalid date format: {date}. Expected one of: {', '.join(accepted_formats)}."
    )


def resource_path(filename):
    """Get absolute path to resource (works for dev and PyInstaller)"""
    if hasattr(sys, "_MEIPASS"):
        return os.path.join(sys._MEIPASS, filename)
    return os.path.abspath(filename)
