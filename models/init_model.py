import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import create_engine

from models.base import Base
from models.holiday_config_model import HolidayConfig
from models.level_config_model import LevelConfig
from models.main_data_model import MainData
from models.result_model import Result

if __name__ == "__main__":
    engine = create_engine("sqlite:///database.db", echo=True)
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
