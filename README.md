# Veracode Pipeline Scan

Perform a Veracode Pipeline Scan and, optionally, compare the results against the provided baseline file.
An example of how to persist a baseline file from a certain branch (e.g. `main`) is outlined below.

See [About the Veracode Pipeline Scan](https://help.veracode.com/r/c_about_pipeline_scan) for more details.

## Inputs

### Required Inputs

The following input parameters are required for the pipeline scan.

|Parameter | Description |
| --- | --- |
|`vid` | The Veracode API ID |
|`vkey` | The Veracode API Secret Key |
|`filename` | The path of the file to scan (e.g. `bundle.zip` or `app.jar`) |

### Optional Inputs

The following input parameters are available to customize the pipeline scan configuration.

|Parameter | Default Value | Description |
| --- | --- | --- |
|`results` | `results.json` | The path where the pipeline json result file should get written |
|`baseline` | `baseline.json` | The path to the pipeline json baseline file. Set to an empty string to disable baseline comparisons |
|`timeout` | `60` | The number of minutes to wait for a scan to complete (60 min max) |
|`severity` | `Very High, High` | The severities that, if found, will cause the scan to fail |
|`cwe` | `""` | The CWEs that, if found, will cause the scan to fail. By default, all CWEs are in scope (depending on severity) |
|`appid` | `""` | The Veracode Platform application ID (only for analytics, results are not sent to the Platform) |
|`allowfail` | `true` | Determines if the scan results can cause the build to fail. Set to false to always succeed |

## Example Usage

### Always succeed scan

This example will scan a single `jar` file, but always succeeds the job regardless of findings.
This example does not compare with any baseline scan.
_Note: an error with the scan will still cause a job failure._

```yaml
- uses: SnowboundSoftware/veracode-pipeline-with-baseline@latest
  continue-on-error: false
  with:
    vid: ${{ secrets.VERACODE_API_ID }}
    vkey: ${{ secrets.VERACODE_API_KEY }}
    filename: target/app.jar
    baseline:
    allowfail: false
```

### Save baseline for `main` branch

This example will scan a single `jar` file and compare the results against an available baseline.
If the job is running on the `main` branch, save the new results as the baseline for future scans.

```yaml
run_scan:
  name: Run Veracode Pipeline Scan
  runs-on: ubuntu-latest
  steps:
    - name: Fetch Baseline File
      continue-on-error: true
      uses: actions/download-artifact@v2
      with:
        name: veracode-baseline
    - name: Run Scan and Compare with Baseline
      uses: SnowboundSoftware/veracode-pipeline-with-baseline@latest
      continue-on-error: false
      with:
        vid: ${{ secrets.VERACODE_API_ID }}
        vkey: ${{ secrets.VERACODE_API_KEY }}
        filename: target/app.jar
        baseline: baseline.json
    - name: Copy Results to Baseline
      if: ${{ github.ref == 'refs/heads/main' }}
      run: cp results.json baseline.json
      shell: bash
    - name: Save New Baseline
      if: ${{ github.ref == 'refs/heads/main' }}
      uses: actions/upload-artifact@v2
      with:
        name: veracode-baseline
        path: baseline.json
```
