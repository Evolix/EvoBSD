#!/bin/sh

EvoComputerName=$(hostname -s)
dnsPTRrecord=$(hostname)
HardwareMark=$(sysctl hw.vendor| sed 's#hw.vendor=##')
HardwareModel=$(sysctl hw.product| sed 's#hw.product=##')
computerIP=$(ifconfig egress | grep inet | awk -v OFS="\n" '{ print $2, $NF }'| head -1)
computerOS=OpenBSD
computerKernel=$(sysctl kern.osrelease | sed 's#kern.osrelease=##')
HardwareSerial=$(sysctl hw.serialno| sed 's#hw.serialno=##')
clientNumber="XXX"
cpuMark=$(sysctl hw.model| sed 's#hw.model=##')
cpuModel=$(sysctl hw.model| sed 's#hw.model=##')
cpuFreq=$(sysctl hw.cpuspeed| sed 's#hw.cpuspeed=##')
mem=$(expr $(sysctl hw.physmem| sed 's#hw.physmem=##') / 1000000)Mo
eth0Mark=unknown
eth0Model=unknown
eth0MAC=$(ifconfig egress | awk -v OFS="\n" '{ print $2, $NF }' | head -3 | tail -1)
eth0IP=$(ifconfig egress | grep inet | awk -v OFS="\n" '{ print $2, $NF }'| head -1)
screen0Mark=none
screen0Model=none
sdaSize=100G
sdaModel=unknown
swap=unknown
nrpeVersion=$(pkg_info nrpe | head -1 | sed  's/Information for inst://')
openvpnVersion=$(pkg_info openvpn | head -1 | sed  's/Information for inst://')
opensshFingerprintRSA=$(ssh-keyscan -t rsa localhost 2>/dev/null\
      | sed -e 's/localhost //' -e 's/ssh-rsa /ssh-rsa,/')
opensshFingerprintED25519=$(ssh-keyscan -t ed25519 localhost 2>/dev/null\
      | sed -e 's/localhost //' -e 's/ssh-ed25519 /ssh-ed25519,/')
opensshFingerprintECDSA=$(ssh-keyscan -t ecdsa-sha2-nistp256 localhost 2>/dev/null\
      | sed -e 's/localhost //' -e 's/ecdsa-sha2-nistp256 /ecdsa-sha2-nistp256,/')
Fingerprint="${opensshFingerprintRSA}${opensshFingerprintRSA:+;}"\
"${opensshFingerprintED25519}${opensshFingerprintED25519:+;}${opensshFingerprintECDSA}"

cat<<EOT>/root/${EvoComputerName}.ldif
# ldapvi --profile evolix --add --in ${EvoComputerName}.ldif

dn: EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
dnsArecord: $EvoComputerName
EvoComputerName: $EvoComputerName
HardwareMark: $HardwareMark
HardwareModel: $HardwareModel
dnsZone: evolix.net
objectClass: EvoComputer
objectClass: top
computerIP: $computerIP
dnsPTRrecord: $dnsPTRrecord
computerOS: $computerOS
computerKernel: $computerKernel
isActive: TRUE
NagiosEnabled: TRUE
NagiosComments: icmp,everytime,10
HardwareSerial: $HardwareSerial
clientNumber: $clientNumber

dn: HardwareName=cpu0,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
HardwareMark: $cpuMark
objectClass: EvoHardware
HardwareName: cpu0
HardwareSize: $cpuFreq
HardwareType: CPU
HardwareModel: $cpuModel

dn: HardwareName=ram0,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
HardwareName: ram0
objectClass: EvoHardware
HardwareSize: $mem
HardwareType: mem
NagiosEnabled: TRUE

dn: HardwareName=eth0,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
HardwareMark: $eth0Mark
objectClass: EvoHardware
HardwareName: eth0
HardwareSize: 1Gigabit
HardwareType: netcard
HardwareAddress: $eth0MAC
HardwareModel: $eth0Model
HardwareIP: $eth0IP

dn: HardwareName=screen0,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
HardwareMark: $screen0Mark
HardwareName: screen0 
objectClass: EvoHardware
HardwareModel: $screen0Model
HardwareType: video

dn: HardwareName=sda,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
objectClass: EvoHardware
HardwareName: sda
HardwareSize: $sdaSize
HardwareType: disk
HardwareModel:${sdaModel}
HardwarePartitioncount: 1
NagiosEnabled: TRUE

dn: HardwareName=swap,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
objectClass: EvoHardware
HardwareName: swap
HardwareSize: $swap
HardwareType: mem
NagiosEnabled: TRUE

dn: ServiceName=nrpe,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
NagiosEnabled: TRUE
ipServiceProtocol: TCP
ServiceVersion: $nrpeVersion
objectClass: EvoService
ServiceName: nrpe
ipServicePort: 5666
ServiceType: monitoring

dn: ServiceName=openssh,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
ipServiceProtocol: tcp
NagiosEnabled: TRUE
ServiceFingerprint: $Fingerprint
objectClass: EvoService
ipServicePort: 22
ServiceName: openssh
ServiceType: ssh
ServiceVersion: OpenSSH 6.7

dn: ServiceName=opensmtpd,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
ipServiceProtocol: tcp
NagiosEnabled: TRUE
objectClass: EvoService
ServiceName: opensmtpd
ipServicePort: 25
ServiceType: smtp
ServiceVersion: OpenSMTPD 5.4.3

dn: ServiceName=ntp,EvoComputerName=${EvoComputerName},ou=computer,dc=evolix,dc=net
NagiosEnabled: TRUE
objectClass: EvoService
ServiceName: ntp
ServiceType: ntp
ServiceVersion: OpenNTPd 4.6

EOT
