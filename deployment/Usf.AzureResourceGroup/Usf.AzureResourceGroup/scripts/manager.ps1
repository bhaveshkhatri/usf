Param(
    [Parameter(Mandatory=$true)] [boolean]$Full = $false,
    [Parameter(Mandatory=$true)] [string]$RedisHost = '',
    [Parameter(Mandatory=$true)] [string]$RedisPassword = ''
)

$erroractionpreference = "Stop"

Write-Host "Manager node says: 'Hello World!'"
if($Full -eq $True){
    Install-Module -Name Azure -Force -AllowClobber
    Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -Update -Force
    Install-Package RespClient -Source "http://packages.nuget.org/v1/FeedService.svc/" -Verbose -Force
    Import-Module "C:\Program Files\PackageManagement\NuGet\Packages\RespClient.1.1.13\content\RespClient.dll"
    #Remove-Module RespClient
    #Install-Package StackExchange.Redis -Source "http://packages.nuget.org/v1/FeedService.svc/" -Verbose -Force
    #Import-Module "C:\Program Files\PackageManagement\NuGet\Packages\StackExchange.Redis.1.2.1\lib\net45\StackExchange.Redis.dll"
    #Remove-Module StackExchange.Redis
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

Connect-RedisServer -Host $RedisHost -Port 6379
Send-RedisCommand "auth $($RedisPassword)"
Send-RedisCommand "set managerJoinToken $($managerJoinToken)"
Send-RedisCommand "set workerJoinToken $($workerJoinToken)"
Disconnect-RedisServer