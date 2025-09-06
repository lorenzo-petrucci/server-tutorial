<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Tutorial</title>
    <style>
        body {
            font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background: #f9fafb;
            color: #1f2937;
        }

        article {
            max-width: 850px;
            margin: 3rem auto;
            padding: 2rem;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        h1, h2, h3 {
            font-weight: 600;
            color: #111827;
            margin-top: 2rem;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 2rem;
            text-align: center;
            margin-bottom: 2rem;
        }

        h2 {
            font-size: 1.5rem;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0.3rem;
        }

        p {
            margin: 1rem 0;
        }

        ul {
            padding-left: 1.5rem;
            margin: 1rem 0;
        }

        li {
            margin-bottom: 0.5rem;
        }

        pre {
            background: #1e293b;
            color: #f8fafc;
            padding: 1rem;
            border-radius: 8px;
            overflow-x: auto;
            margin: 1rem 0;
        }

        code {
            font-family: "Fira Code", monospace;
            font-size: 0.9rem;
        }

        pre code {
            color: #f1f5f9;
        }

        p code, li code {
            background: #f3f4f6;
            padding: 0.2rem 0.4rem;
            border-radius: 4px;
            font-size: 0.9rem;
            color: #374151;
        }

        strong {
            color: #2563eb;
        }

        @media (max-width: 768px) {
            article {
                margin: 1rem;
                padding: 1.5rem;
            }

            h1 {
                font-size: 1.6rem;
            }

            h2 {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
<article>
    <h1>Building and Deploying a Java Web Server with Terraform, Ansible, and Docker</h1>

    <h2>1. Overview</h2>
    <p>
        This project is designed as a tutorial: the goal is not to provide a production-ready
        stack, but to give a hands-on way to learn how infrastructure provisioning, configuration
        management, and deployment automation work together.
        By following the steps, you learn how to create a virtual server on a cloud provider,
        configure it remotely, and deploy a simple Java application in a repeatable and automated way.
    </p>
    <p>
        The project makes use of modern infrastructure as code and automation tools. Each layer
        focuses on a different responsibility: provisioning resources, configuring the system,
        and running the application inside a container. While the technologies used here are
        just one possible combination, the workflow demonstrates the general approach to
        building automated deployment pipelines.
    </p>

    <h2>2. Setup</h2>
    <p>Configure AWS CLI profile:</p>
    <pre><code>aws configure --profile server-tutorial</code></pre>

    <p>Generate SSH key pair:</p>
    <pre><code>ssh-keygen -t rsa -f ~/.ssh/server_tutorial</code></pre>

    <h2>3. Provisioning with Terraform</h2>
    <p>
        The configuration defines provider, networking, access, compute resources, and an Ansible inventory file.
        Example snippets:
    </p>

    <pre><code class="language-hcl">provider "aws" {
  region  = "eu-central-1"
  profile = "server-tutorial"
}

resource "aws_security_group" "server-tutorial" {
  name   = "server-tutorial-name"
  vpc_id = aws_default_vpc.server-tutorial.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server-tutorial" {
  ami                    = "ami-04a8220c151d8840a"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.server-tutorial.key_name
  vpc_security_group_ids = [ aws_security_group.server-tutorial.id ]
  tags = { Name = "server tutorial" }
}

resource "local_file" "hosts" {
  content = templatefile("../ansible/inventory.tmpl", {
    value = aws_instance.server-tutorial.public_ip
  })
  filename = "../ansible/hosts"
}</code></pre>

    <p>This produces an inventory file consumed by Ansible, e.g.:</p>
    <pre><code id="host"></code></pre>

    <p>Apply with:</p>
    <pre><code>make terraform</code></pre>

    <h2>4. Configuration with Ansible</h2>
    <p>
        The playbook installs Docker on the remote host, copies the application WAR, and
        runs a Tomcat container with the application mounted into its <code>webapps/</code> directory.
        This way the WAR is immediately deployed without requiring a custom image build.
    </p>

    <pre><code class="language-yaml">- name: Copy backend to host
  ansible.builtin.copy:
    src: ../../code/target/server-tutorial.war
    dest: /tmp/target/
    mode: "0755"

- name: Update apt and install docker-ce
  ansible.builtin.apt:
    name: docker-ce
    state: latest
    update_cache: true

- name: Ensure container is absent
  community.docker.docker_container:
    name: "{{project}}"
    state: absent

- name: Start container
  community.docker.docker_container:
    name: "{{project}}"
    image: "tomcat:11.0.1-jdk21-temurin-noble"
    state: started
    restart_policy: always
    ports: "80:8080"
    volumes:
      - "/tmp/target:/usr/local/tomcat/webapps/"</code></pre>

    <p>Compile the code and trigger the Ansible playbook:</p>
    <pre><code>make deploy</code></pre>

    <h2>5. Test</h2>
    <p>
        The deployed endpoint can be tested clicking <span id="link"></span> or with:
    </p>
    <pre><code id="request"></code></pre>

    <p>Example response:</p>
    <pre><code id="response"></code></pre>

    <h2>6. Summary</h2>
    <p>
        Terraform provisions the AWS environment and generates inventory;
        Ansible configures the host, installs Docker, and runs Tomcat with the deployed WAR.
        The workflow is minimal but shows the full cycle of provisioning, configuring, and deploying a Java application in the cloud.
    </p>
    <footer>The project can be found on <a href="https://github.com/lorenzo-petrucci/server-tutorial.git" target="_blank">GitHub</a>.</footer>
</article>
</body>
<script>
    const HOST = window.location.host
    const DATE = new Date().toGMTString();

    console.log(HOST);
    document.getElementById("link").innerHTML = "<a href=" + window.location.href + " target=\"_blank\">here</a>";
    document.getElementById("host").innerHTML = HOST;
    document.getElementById("request").innerHTML = `curl ${HOST}/server-tutorial/api -vvv`;
    document.getElementById("response").innerHTML = `*   Trying ${HOST}:80...
* Connected to ${HOST} (${HOST}) port 80 (#0)
> GET /server-tutorial/api HTTP/1.1
> Host: ${HOST}
> User-Agent: curl/7.88.1
> Accept: */*
>
< HTTP/1.1 200
< Content-Type: application/json
< Transfer-Encoding: chunked
< Date: ${DATE}
<
* Connection #0 to host ${HOST} left intact
"Hello World!"`;
</script>
</html>
