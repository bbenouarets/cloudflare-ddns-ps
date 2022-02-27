# requires - Version 7.1
function Send-Webhook {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Message
    )

    $body = @{
        "content" = $Message
    }

    Invoke-RestMethod -Method POST -Uri $Url -Body $body

}

function Send-WebhookTeams {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [string]$DNS,
        [Parameter(Mandatory)]
        [string]$Old_IP,
        [Parameter(Mandatory)]
        [string]$New_IP,
        [Parameter(Mandatory)]
        [string]$Date,
        [Parameter(Mandatory)]
        [string]$Image
    )

    $body = @{
        "@type" = "MessageCard"
        "@context" = "http://schema.org/extensions"
        "themeColor" = "0072C6"
        "summary" = $Title
        "sections" = @(
            @{
                "activityTitle" = $Title
                "activitySubtitle" = $DNS
                "activityImage" = $Image
                "facts" = @(
                    @{
                        "name" = "Old IP Address"
                        "value" = $Old_IP
                    },
                    @{
                        "name" = "Updated IP Address"
                        "value" = $New_IP
                    },
                    @{
                        "name" = "Date of Update"
                        "value" = $Date
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Method POST -Uri $Url -Body $body -ContentType "Application/Json"

}

function Update-DNSRecord {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        $Email,
        [parameter(Mandatory)]
        $Token,
        [parameter(Mandatory)]
        $ZoneID,
        [parameter(Mandatory)]
        $DNSRecord,
        [parameter(Mandatory)]
        $Notification,
        [parameter(Mandatory)]
        $NotificationURL,
        [parameter(Mandatory)]
        $NotificationImage
    )

    $auth_token = "Bearer $Token"

    $headers = @{
        "Authorization" = $auth_token
    }

    $uri = "https://api.cloudflare.com/client/v4/user/tokens/verify"
    $res = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -Body $null

    if (!$res.success) {
        Write-Host "❌ Error: Token cannot be verified!"
        return
    }

    $headers = @{
        "X-Auth-Email" = $Email
        "Authorization" = $auth_token
        "Content-Type" = "application/json"
    }

    # Get IP address of record
    $uri = "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$DNSRecord"
    $res = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -Body $null
    $DNSID = $res.result[0].id
    $TTL = $res.result[0].ttl
    $old_ip = $res.result.content
    $ip = Invoke-RestMethod -Method Get -Uri "https://api.ipify.org" -Body $null

    if ($old_ip -eq $ip) {
        Write-Host "❌ Error: IP address is already set to $ip"
        return
    } 

    $body = @{
        "type" = "A"
        "name" = $DNSRecord
        "content" = $ip
        "proxied" = $true
        "ttl" = $TTL
    } | ConvertTo-Json

    $uri = "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$DNSID"

    $res = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body

    if (!$res.success) {
        Write-Host "❌ Error: DNS record cannot be updated!"
        return
    }
        
    Write-Host "✅ DNS record updated successfully!"
    $date = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
    Write-Host "📌 Notification: $Notification"
    try {
        if ($Notification -eq "Teams") {
            Write-Host "📩 Sending notification via Teams..."
            Send-WebhookTeams -Url $NotificationURL -Title "DNS Updated" -DNS $DNSRecord -Old_IP $old_ip -New_IP $ip -Date $date -Image $NotificationImage
        } elseif ($Notification -eq "Webhook") {
            Write-Host "📩 Sending notification via Webhook..."
            $NotificationMessage = (
                "Updated DNS record: $DNSRecord to $ip at $date"
            )
            Send-Webhook -Url $NotificationURL -Message $NotificationMessage
        } else {
            Write-Host "❌ Error: Notification method not supported!"
            return
        }
    } catch {
        Write-Host "❌ Error: Notification failed!"
        return
    }
}