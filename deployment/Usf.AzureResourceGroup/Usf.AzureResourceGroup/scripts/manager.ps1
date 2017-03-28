Param(
    [Parameter()] [boolean]$Full = $false
)

$erroractionpreference = "Stop"

Write-Host "Manager node says: 'Hello World!'"
if($Full -eq $True){
    Install-Module -Name Azure -Force -AllowClobber
    Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -Update -Force
}

Stop-Service docker -Verbose
Start-Service docker -Verbose
try{
    docker node ls
    docker swarm leave --force
}
catch [System.Exception]{
}

$ipAddress = (Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress

$initOutput = docker swarm init --listen-addr=$ipAddress --advertise-addr=$ipAddress
$managerJoinToken = docker swarm join-token -q manager
$workerJoinToken = docker swarm join-token -q worker

$splitOutput = $initOutput -split ' '
$tokenIndex = $splitOutput.indexOf('--token')
$port = ($splitOutput[$tokenIndex+7] -split ':')[1]

Write-Host 'Manager Join Token:  ' $managerJoinToken
Write-Host 'Worker Join Token:   ' $workerJoinToken
Write-Host 'Manager IP:          ' $ipAddress
Write-Host 'Manager Port:        ' $port
