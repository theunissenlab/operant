import usb.core
import usb.util
from usb.backend import libusb0

# find our device
dev = usb.core.find(idVendor=0x09db, backend=libusb0.get_backend())

# was it found?
if dev is None:
    raise ValueError('Device not found')

# if dev.is_kernel_driver_active(0) is True:
#   # tell the kernel to detach
#   dev.detach_kernel_driver(0)
#   # claim the device
#   usb.util.claim_interface(dev, 0)

# get an endpoint instance
cfg = dev[0]
intf = cfg[(0,0)]

ep = usb.util.find_descriptor(
    intf,
    # match the first OUT endpoint
    custom_match = \
    lambda e: \
        usb.util.endpoint_direction(e.bEndpointAddress) == \
        usb.util.ENDPOINT_OUT)

assert ep is not None

