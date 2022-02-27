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