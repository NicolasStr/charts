# NicolasStr's Helm Chart Repository

Welcome to my Helm Charts repository! This project contains a collection of Helm charts that I maintain and share with the community. These charts are designed to help you deploy and manage some applications on Kubernetes with ease.

## Purpose

The goal of this repository is to provide reusable, well-documented, and community-driven Helm charts. Feel free to use these charts in your projects or contribute improvements and new charts to the repository.

## Helm Charts

### Available Charts

- **twenty**: A Helm chart for deploying the `twenty` application.

Each chart is located in its own directory and includes all the necessary templates, values, and documentation to get started.

## Getting Started

To use a chart from this repository:

1. Clone the repository:
   ```bash
   helm repo add nicolasstr_charts https://nicolas.streng.sh/charts/
   helm repo update
   ```

2. Navigate to the desired chart directory (e.g., `charts/twenty`).

3. Install the chart using Helm:
   ```bash
   helm install nicolasstr_charts/<release-name>
   ```

4. Customize the deployment by editing the `values.yaml` file or passing `--set` options during installation.

## Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository and create a new branch for your changes.
2. Make your changes and ensure they follow best practices.
3. Submit a pull request with a clear description of your changes.

Please ensure your contributions are well-documented and tested.

## License

This repository is licensed under the [MIT License](https://opensource.org/licenses/MIT). You are free to use, modify, and distribute the charts in accordance with the terms of this license.

## Feedback

If you encounter any issues or have suggestions for improvement, feel free to open an issue or start a discussion.

Happy charting!