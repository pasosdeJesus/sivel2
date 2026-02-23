# SIVeL 2.3 - The Core Data Engine of SIVeL 3

**This is the codebase for SIVeL 2.3, the robust data management system at the heart of the SIVeL 3 platform.**

[![Monorepo](https://img.shields.io/badge/monorepo-sivel3-blue.svg)](https://github.com/pasosdeJesus/sivel3)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com) 
[![GitLab CI](https://gitlab.com/pasosdeJesus/sivel2/badges/main/pipeline.svg)](https://gitlab.com/pasosdeJesus/sivel2/-/pipelines?page=1&scope=all&ref=main) 
[![GitHub CI](https://github.com/pasosdeJesus/sivel2/actions/workflows/rubyonrails.yml/badge.svg?branch=main)](https://github.com/pasosdeJesus/sivel2/actions/workflows/rubyonrails.yml) 
[![CodeQL](https://github.com/pasosdeJesus/sivel2/actions/workflows/github-code-scanning/codeql/badge.svg?branch=main)](https://github.com/pasosdeJesus/sivel2/actions/workflows/github-code-scanning/codeql)

![SIVeL 2 Logo](https://gitlab.com/pasosdeJesus/sivel2/-/raw/main/app/assets/images/logo.png)

## About SIVeL 2.3

SIVeL 2.3 is a mature and reliable Ruby on Rails application that functions as the primary backend for the SIVeL 3 ecosystem. It is responsible for the detailed documentation of socio-political violence cases, managed by a team of professional human rights documenters.

### Role in the SIVeL 3 Architecture

In the current SIVeL 3 architecture, this application plays a critical role:

*   **The Authoritative Data Engine:** It provides the core data management system, offering a stable and secure environment for creating, editing, and storing case information in a PostgreSQL database.
*   **Legacy and Stability:** As a legacy system, its stability is a cornerstone of our data integrity strategy. It will continue to be the primary tool for documenters while we progressively and carefully build out new functionalities in the Next.js layer.
*   **Gradual Transition:** Over time, functionalities of `sivel2` will be migrated to the new `next.js` application. This transition is being managed with a security-first approach, ensuring that the SIVeL 3 platform remains robust and reliable.

This application is part of the SIVeL 3 monorepo. For a complete overview of the entire project, its vision, and its architecture, please refer to the main **[SIVeL 3 README.md](https://gitlab.com/pasosdeJesus/sivel3/-/blob/main/README.md)**.
