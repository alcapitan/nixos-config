{ pkgs, ... }:

{
  environment.extraInit = ''
    umask 077
  '';

  users.users.alex = {
    isNormalUser = true;
    description = "Al Capitan";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "adbusers" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhQpiw6V5z5Zp02BL2z74W5UYuhLhmbgQrpvaLhUr7+U0Uclc+ZhIe4l1swimb31EiewD+wuXSNEhl3fNwPX7Oa+ofwYKZbNDERGn1XHl5LuNYDJWDOQmB3GQL2ZpXvHkn4IRB4onesRK9un7i5/VgdmUbp7micRPGRLiuHcS18TpbGxs5cZr08CqN2o0Tc+n4HcV+Ebz6k3i6dxaZUyzNSqZiKMgdRF9ja129UhjRJlinX3ds1HKHrWp84w1DsMpnAUVARPoyXxOTHRGGA4qyWO02Rv3X1wxJIHs9AljoAoIvFyPTQBmrr3X3SQgMu5PHQvFB4x38B38w8WH35TAhJs8XaL4hES2IkczjnvSr9CH0IwNC6I+RRDxzs5R2WoJlkbCxKCWeOiY7TqFjSHR7ExriqmnDLf8x4dDDVLxUYkNbs9j20sBtsD16AHsIwykLJManOpiBkSMKCAduZc/jFRWLXV1wbi4uHTCqwwx5+5VvgyVIOWDmuk62wQXtO4zi5IOgbUNAI57C3A2Y93W/ITPA4WrHi4tWgegmwMozkQwMr2ui3NhpYK9J8HF/wjRqCI3sV9PxQdTeXxOKU4pgss1ehBt58g3h3YRU0GeFGSKkAJJsfV3lwD2DiDpfTem0mZa50XEHof1VyjomVaQ4Pks+BOIyLYO/ENoimuozbQ== openpgp:0x3991FE90"
    ];
  };

  /*
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nproc"; value = "100"; } # pas plus de 100 processus par user
    { domain = "*"; type = "hard"; item = "nproc"; value = "300"; } # pas plus de 300 processus par user
    { domain = "*"; type = "soft"; item = "fsize"; value = "3145728"; } # taille max fichier 3 Go
    { domain = "*"; type = "hard"; item = "fsize"; value = "6291456"; } # taille max fichier 6 Go
    { domain = "*"; type = "hard"; item = "memlock"; value = "524288"; } # pas plus de 512Mo RAM par user
    { domain = "*"; type = "hard"; item = "cpu"; value = "30"; } # pas plus de 30 minutes de CPU
    { domain = "root"; type = "hard"; item = "nproc"; value = "unlimited"; } # désactive restriction processus pour root
    { domain = "root"; type = "soft"; item = "nproc"; value = "unlimited"; }
  ];*/
}