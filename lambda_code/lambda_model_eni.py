from datetime import datetime


class Eni:

    def __init__(self,
                 eni_id: str,
                 private_ip: str,
                 public_ip: str,
                 mac_address: str,
                 type: str,
                 resource_name: str,
                 available_from: datetime,
                 region: str,
                 account: str):
        self.eni_id: str = eni_id
        self.private_ip: str = private_ip
        self.public_ip: str = public_ip
        self.mac_address: str = mac_address
        self.type: str = type
        self.resource_name: str = resource_name
        self.available_from: datetime = available_from
        self.region: str = region
        self.account: str = account

    def __eq__(self, other):
        result: bool = False
        if isinstance(other, self.__class__):
            result = self.eni_id == other.eni_id

        return result

    def __ne__(self, other):
        return not self.__eq__(other)
