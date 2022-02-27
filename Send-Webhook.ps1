function Send-Webhook {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Message
    )

    $body = @{
        "content" = $Message
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Method POST -Uri $Url -Body $body

}