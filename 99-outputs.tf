# ================================================================================================================
# Variables
# ================================================================================================================

resource "local_file" "profile_file" {
    content = templatefile( "./scripts/profile.share.tpl",
    {
        lb_endpoint  = aws_lb.delta_sharing_lb.dns_name,
        bearer_token = "faaie590d541265bcab1f2de9813274bf233"
    })
    filename = "./files/profile.share"
}