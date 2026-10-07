# Architecture: campus-portal

What [`../terraform-project`](../terraform-project) builds, for `environment = dev` in
`ap-south-1`.

```mermaid
flowchart TB
    user(["Browser"]) -->|HTTP :80| igw
    admin(["Admin 198.51.100.24/32"]) -->|SSH :22| igw

    subgraph region["AWS region ap-south-1"]
        subgraph vpc["VPC campus-portal-dev-vpc · 10.40.0.0/16"]
            igw["Internet Gateway"]
            rt["Public route table<br/>10.40.0.0/16 → local<br/>0.0.0.0/0 → IGW"]

            subgraph aza["AZ ap-south-1a"]
                pubA["Public subnet 10.40.1.0/24"]
                web1["EC2 web-1<br/>t3.micro · Ubuntu 24.04<br/>nginx via user_data"]
                privA["Private subnet 10.40.101.0/24<br/>(reserved for a DB tier)"]
            end

            subgraph azb["AZ ap-south-1b"]
                pubB["Public subnet 10.40.2.0/24"]
                web2["EC2 web-2<br/>(when web_instance_count = 2)"]
            end

            sg["Security group web-sg<br/>in: 80 from 0.0.0.0/0<br/>in: 22 from admin_cidr<br/>out: all"]
        end

        s3[("S3 campus-portal-dev-site-&lt;hex&gt;<br/>versioned · AES256 · no public access<br/>site/index.html")]
        role["IAM role web-role<br/>+ instance profile<br/>s3:ListBucket, s3:GetObject site/*"]
    end

    igw --- rt
    rt --- pubA
    rt --- pubB
    pubA --- web1
    pubB --- web2
    sg -.-> web1
    sg -.-> web2
    role -.->|instance profile| web1
    role -.->|instance profile| web2
    web1 -->|"aws s3 cp at first boot"| s3
    web2 --> s3
```

## Request and boot flow

1. `terraform apply` uploads `site/index.html` to the bucket **before** creating the instances
   (`depends_on = [aws_s3_object.index]`).
2. Each instance boots in a public subnet, receives a public IP (`map_public_ip_on_launch`), and
   runs its rendered `user_data`: set the hostname, install nginx and AWS CLI v2, copy the page
   from S3, start nginx.
3. The S3 download is authorised by the **instance profile**: the CLI fetches temporary role
   credentials from the instance metadata service (IMDSv2 required on real AWS). No access key
   exists anywhere on the machine.
4. A browser reaches the instance on port 80 through the Internet Gateway; the security group
   admits 80 from anywhere and 22 only from `admin_cidr`.

## Dependency graph

Generated with `terraform graph | dot -Tpng`. Arrows point from a resource to what it depends
on:

![terraform graph](terraform-graph.png)

## Design choices

| Choice | Why |
|---|---|
| Subnet CIDRs from `cidrsubnet(var.vpc_cidr, 8, n)` | Changing `vpc_cidr` re-plans every subnet consistently; no hard-coded addresses |
| `count` + `count.index % public_subnet_count` | Instances spread round-robin over AZs as `web_instance_count` grows |
| Separate private subnet with no IGW route | The place for a future RDS instance; nothing in it is reachable from the internet |
| Random hex suffix on the bucket | S3 names are global; repeated `apply`/`destroy` cycles never collide |
| `user_data_replace_on_change = true` | A changed boot script produces a fresh instance instead of being silently ignored |
| IAM role instead of keys | Credentials rotate automatically and cannot leak from the instance |
| Encrypted gp3 root volume, IMDSv2 | Secure defaults that cost nothing |

---

**Prince Shakya** · Roll No. 24BCS10084
