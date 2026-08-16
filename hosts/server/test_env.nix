{ ... }:

{
    virtualisation.vmVariant = {
        virtualisation = {
            memorySize = 4096; # 4 GB RAM
            cores = 2;         # 2 vCPU
            diskSize = 40900;  # 40 GB Disk

            # graphics = false;

            forwardPorts = [
                { from = "host"; host.address = "127.1.0.1"; host.port = 8000; guest.port = 80; }
                { from = "host"; host.address = "127.1.0.1"; host.port = 8443; guest.port = 443; }
                { from = "host"; host.address = "127.1.0.1"; host.port = 2222; guest.port = 2222; }
                { from = "host"; host.address = "127.1.0.1"; host.port = 2223; guest.port = 22; }
                { proto = "tcp"; from = "host"; host.address = "127.1.0.1"; host.port = 5353; guest.port = 53; }
                { proto = "udp"; from = "host"; host.address = "127.1.0.1"; host.port = 5353; guest.port = 53; }
            ];
        };
    };
}