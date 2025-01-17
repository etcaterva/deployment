variable "usernames" {
  default = ["pedro.alvarez", "mario.corchero", "david.naranjo"]
}

resource "aws_iam_group" "admin_group" {
  name = "admin"
}

resource "aws_iam_group_policy_attachment" "admin_group_policy_attachment" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_login_profile" "admin_user_login_profile" {
  for_each             = toset(var.usernames)
  user                 = aws_iam_user.admin_user[each.key].name
  password_length      = 12
  password_reset_required = true
}

resource "aws_iam_user_group_membership" "admin_user_group_membership" {
  for_each = toset(var.usernames)
  user     = aws_iam_user.admin_user[each.key].name
  groups = [
    aws_iam_group.admin_group.name,
  ]
}

resource "aws_iam_policy" "mfa_enforce_policy" {
  name        = "mfa-enforce-policy"
  description = "Enforces MFA for IAM users."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Action": "*",
        "Resource": "*",
        "Condition": {
          "BoolIfExists": {
            "aws:MultiFactorAuthPresent": "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "mfa_enforce_policy_attachment" {
  for_each = toset(var.usernames)
  user     = aws_iam_user.admin_user[each.key].name
  policy_arn = aws_iam_policy.mfa_enforce_policy.arn
}

output "user_passwords" {
  value = {
    for username in var.usernames : username => aws_iam_user_login_profile.admin_user_login_profile[username].password
  }
  sensitive = true
}
