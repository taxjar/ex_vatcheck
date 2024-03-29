#### 0.3.1 (2022-08-31)

##### Bug Fixes

* Fixes change to business name fetched in the smoke test.

#### 0.3.0 (2022-08-31)

##### Breaking Bug Fixes

* Updates XML parsing logic to work with new VIES SOAP envelope namespace changes.
* Better error handling if `SweetXml.xpath` returns an error and parsing fails.

#### 0.2.1 (2021-10-13)

##### Chores

* Trade Travis-CI for GitHub Actions, and update test pipeline to cover
    combinations of Elixir and OTP versions.
* Drop support for Elixir 1.4 thru 1.5. This wasn't true even before this
  commit, but better testing confirmed this.

#### 0.2.0 (2021-10-13)

##### Security

* **security:** Lock to SweetXML 0.7.x to disable DTD fetching and parsing.

#### 0.1.5 (2020-03-19)

##### Bug Fixes

* **vies-client:** Ensure client url is using https ([#7](https://github.com/taxjar/ex_vatcheck/pull/7))

#### 0.1.4 (2020-03-19)

##### Bug Fixes

* **vies-client:** Update url to https to avoid invalid XML redirect ([#5](https://github.com/taxjar/ex_vatcheck/pull/5))

#### 0.1.3 (2019-05-10)

##### Bug Fixes

* **normalize:** use normalized vat for validation ([#4](https://github.com/taxjar/ex_vatcheck/pull/4))

#### 0.1.2 (2019-05-09)

##### Bug Fixes

* **vies-response:** fix formatting inconsistencies in vies_response fields ([#3](https://github.com/taxjar/ex_vatcheck/pull/3))

##### Chores

* **open-source:** add necessary files to open source ExVatcheck ([#1](https://github.com/taxjar/ex_vatcheck/pull/1))

##### Docs

* **fix:** tidy up docs ([#2](https://github.com/taxjar/ex_vatcheck/pull/2))

#### 0.1.1 (2019-05-01)

##### Bug Fixes

* **client:** gracefully handle vies wsdl timeouts

### 0.1.0 (2019-04-17)

##### New Features

* **check:** add top-level check method
* **vies:**  add VIES client
