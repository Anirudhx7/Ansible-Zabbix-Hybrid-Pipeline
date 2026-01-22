# Hybrid Infrastructure Observability: Zabbix Automation Pipeline 📊

## 🚀 Project Overview
In a hybrid environment, manually installing monitoring agents is a bottleneck. It leads to "configuration drift," security blind spots, and hours of wasted time.

I engineered this project to treat **Monitoring as Code**.
It creates a unified pipeline that deploys Zabbix Agents to **Linux** and **Windows** servers and automatically registers them to the Zabbix Server via API—reducing a multi-hour onboarding process to **under 5 minutes**.

**Key Capabilities:**
* **Hybrid OS Support:** Dynamic detection and configuration for RHEL/Ubuntu and Windows Server.
* **API-Driven Onboarding:** Zero-touch host creation and template linking via Zabbix API.
* **DevSecOps Standard:** Credentials secured using Ansible Vault (AES-256).
* **Idempotency:** The pipeline can run repeatedly without breaking existing configurations.

## ⚡ The Automation Workflow
I designed the playbook to handle the entire lifecycle of a monitoring agent:

1.  **Reconnaissance:** Ansible gathers facts to detect OS family (Linux vs Windows).
2.  **Deployment:**
    * *Linux:* Configures repositories and installs `zabbix-agent2`.
    * *Windows:* Pushes MSI installers and configures the service via WinRM.
3.  **Configuration:** Deploys a templated `zabbix_agentd.conf` with dynamic variables (Hostname, Server IP, PSK).
4.  **Registration (The Logic):** The system queries the Zabbix API. If the host doesn't exist, it creates it, assigns the correct interface, and links the "Linux/Windows by Zabbix Agent" templates.

## 🛠️ Technical Implementation

### 1. The Orchestrator (Main Playbook)
The entry point acts as a traffic controller. It utilizes `group_vars` to abstract environment specifics (Dev vs Prod) and uses conditional logic (`when: ansible_os_family == ...`) to dynamically apply the correct roles. This ensures a single playbook run can patch a mixed fleet of servers without manual targeting.

### 2. API Registration Logic (Ansible URI Module)
Instead of using the GUI, I automated the registration using the Zabbix JSON-RPC API.
* **Check:** The role first queries the API to see if the host exists to ensure idempotency.
* **Create:** If missing, it constructs a JSON payload with the correct Interface, IP, and Host Group IDs.
* **Link:** It automatically associates the correct templates based on the OS.

### 3. Secure Credential Management
Hardcoding API tokens is a security risk. I implemented **Ansible Vault** to encrypt sensitive data (API users, passwords, and PSK keys) while keeping the codebase usable for the team.

## 🚧 Challenges & Troubleshooting

**1. Windows WinRM Connectivity:**
* *Challenge:* Ansible struggled to connect to Windows hosts initially due to certificate validation issues.
* *Solution:* I tuned the `group_vars/windows.yml` to properly configure `ansible_connection: winrm` and `ansible_winrm_server_cert_validation: ignore` for the lab environment, while enforcing NTLM auth.

**2. Handling JSON Responses:**
* *Challenge:* The Zabbix API returns complex JSON. If a host already existed, the `host.create` method would fail the pipeline.
* *Solution:* I added a pre-check task (`host.get`) to verify existence before attempting creation, ensuring the playbook remains idempotent.

**3. Cross-Platform Pathing:**
* *Challenge:* Linux uses `/etc/zabbix` while Windows uses `C:\Program Files\Zabbix Agent`.
* *Solution:* I abstracted these paths into role-specific `defaults/main.yml` variables, allowing the tasks to remain generic while the variables handled the OS differences.

## 🧠 Learning Outcomes
From this project, I gained hands-on experience in:

* **Infrastructure as Code (IaC):** Moving from manual CLI work to scalable Ansible playbooks.
* **API Integration:** Interacting with REST APIs (Zabbix) programmatically to automate logic.
* **Hybrid Cloud Admin:** Managing state across disparate operating systems (Linux & Windows) simultaneously.
* **Secrets Management:** Implementing Ansible Vault to adhere to DevSecOps best practices.

---

## 📁 Repository Structure
```text
.
├── inventory.example.ini    # Sanitized inventory template
├── playbooks/
│   └── zabbix/
│       └── zabbix_agent_full.yml   # Main orchestrator
├── roles/
│   ├── zabbix_agent_linux   # Package & Config for Linux
│   ├── zabbix_agent_windows # Chocolatey/MSI & Config for Windows
│   └── zabbix_register_host # API interaction for host onboarding
└── group_vars/
    ├── all/
    │   ├── all.yml          # Common vars
    │   └── vault.yml        # Encrypted secrets
    └── windows.yml          # Windows-specific connection vars
```

## 🚀 Usage

### 1. Clone and Setup Inventory
```bash
cp inventory.example.ini inventory.ini
# Edit inventory.ini with your target IPs
```
### 2. Configure Secrets
Create a secure vault file for your Zabbix API credentials:

```bash
ansible-vault create group_vars/all/vault.yml
```
**Add the following content inside the vault:**

```yaml
zabbix_api_url: "[http://monitor.example.com/zabbix/api_jsonrpc.php](http://monitor.example.com/zabbix/api_jsonrpc.php)"
zabbix_api_user: "Admin"
zabbix_api_password: "YOUR_SECURE_PASSWORD"
```
### 3. Run the Playbook
Execute the deployment against your inventory:

```bash
ansible-playbook playbooks/zabbix_deploy.yml -i inventory.ini --ask-vault-pass
```
# 🏁 Final Notes
This project bridges the gap between provisioning and observability. By automating the agent deployment and registration, I ensured that no server is ever deployed without monitoring coverage, maintaining 100% visibility across the infrastructure.

## 🛡️ Security Note
This repository contains an inventory.example.ini and dummy vault variables. Never commit real internal IP addresses or unencrypted passwords to public version control.

LinkedIn: <a href="https://www.linkedin.com/in/anirudh-mehandru/">linkedin.com/in/anirudh-mehandru </a>
