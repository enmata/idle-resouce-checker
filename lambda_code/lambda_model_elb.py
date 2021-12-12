from datetime import datetime


class Elb:

    def __init__(self,
                 lb_name: str,
                 lb_arn: str,
                 tg_arn: str,
                 type: str,
                 available_from: datetime,
                 region: str,
                 account: str):
        self.lb_name: str = lb_name
        self.lb_arn: str = lb_arn
        self.tg_arn: str = tg_arn
        self.type: str = type
        self.available_from: datetime = available_from
        self.region: str = region
        self.account: str = account

    def __eq__(self, other):
        result: bool = False
        if isinstance(other, self.__class__):
            result = (self.tg_arn == other.tg_arn) and \
                     (self.lb_name == other.lb_name) and \
                     (self.lb_name == other.lb_name)

        return result

    def __ne__(self, other):
        return not self.__eq__(other)
