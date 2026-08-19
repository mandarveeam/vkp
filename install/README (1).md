# Veeam Kubernetes Proxy (VKP) Installation on OpenShift

This script automates the installation and initial configuration of **Veeam Kubernetes Proxy (VKP)** on an OpenShift cluster using Helm.

## What the script does

1. **Installs Helm** — downloads and extracts Helm v4.2.3 for Linux (amd64), and adds it to the `PATH` for the current shell session.
2. **Adds the VKP Helm repository** — adds Veeam's staging Helm chart repository and refreshes the local repo cache.
3. **Installs VKP** — deploys the `vkp/vkp` Helm chart into a dedicated namespace, accepting the EULA automatically.
4. **Annotates the VolumeSnapshotClass** — marks the specified `VolumeSnapshotClass` so VKP recognizes it as the snapshot class to use.
5. **Displays the OpenShift Route** — shows the route created for accessing VKP.
6. **Displays all VKP resources** — lists all Kubernetes objects (pods, services, deployments, etc.) created in the VKP namespace.
7. **Retrieves the VKP service account token** — decodes and prints the token used to register VKP with Veeam Backup & Replication.

## Prerequisites

- Access to an OpenShift cluster with the `oc` CLI installed and authenticated (logged in with sufficient privileges to create namespaces and resources).
- `curl` and `tar` available on the machine running the script.
- Outbound network access to `https://get.helm.sh` and `https://staging.charts.veeam.com/`.
- An existing `VolumeSnapshotClass` in the cluster that matches your OpenShift storage provider (e.g., LVMS, ODF, CSI-based storage).

## Configuration

Before running, review and adjust the following variables in the script:

| Variable | Description | Default |
|---|---|---|
| `VKP_NAMESPACE` | Kubernetes namespace where VKP will be installed | `vkp` |
| `VOLUMESNAPSHOTCLASS` | Name of the `VolumeSnapshotClass` used by your storage backend | `lvms-vg1` |

To find the correct `VolumeSnapshotClass` for your cluster, run:

```bash
oc get volumesnapshotclass
```

and update `VOLUMESNAPSHOTCLASS` accordingly.

## Usage

1. Make the script executable:
   ```bash
   chmod +x install-vkp.sh
   ```
2. Run it:
   ```bash
   ./install-vkp.sh
   ```
3. Once complete, the script prints:
   - The OpenShift Route for accessing VKP
   - All resources created in the VKP namespace
   - The service account token needed to register VKP in Veeam Backup & Replication

## Notes

- The Helm binary is downloaded locally and added to `PATH` only for the duration of the script's shell session — it is **not** installed system-wide.
- The `--set eula.accept=true` flag automatically accepts the Veeam End User License Agreement during installation. Review the EULA beforehand if required by your organization's policy.
- The Helm repository used (`https://staging.charts.veeam.com/`) is a **staging** repository. Confirm this is the intended source before using in a production environment.
- The retrieved service account token is sensitive. Handle it securely and avoid printing it in shared terminals or logs.

## Next Steps

After installation, use the printed Route and service account token to register the VKP proxy as a Kubernetes cluster in Veeam Backup & Replication.
