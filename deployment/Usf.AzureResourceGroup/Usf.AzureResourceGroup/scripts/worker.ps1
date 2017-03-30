Param(
    [Parameter()] [boolean]$Full = $false
)

$erroractionpreference = "Stop"

Write-Host "Worker node says: 'Hello World!'"
if($Full -eq $True){
    Install-Module -Name Azure -Force -AllowClobber
    Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -Update -Force
}

Stop-Service docker -Verbose
Start-Service docker -Verbose

#docker swarm join --token SWMTKN-1-3sw3so7ki4kzbk5a0ep4idbnpsacyjig7sgd9iih9lkgpq0d4z-9p1fzc0a2gjz0zd428ffnqktc 10.0.0.6:2377