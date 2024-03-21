# Migrator

An easy-to-use Dart-powered Postgres migration tool semi-inspired by Prisma.

## Overview

The `dart_migrator` package can be installed to your project's dev dependencies and then used to create and run migrations for your Postgres database.

## Usage

### Installation

Add `dart_migrator` to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  dart_migrator: [latest_version]
```

Then run `pub get` to install the package.

### Creating Migrations

To create a new migration, run the following command:

```bash
dart run migrator create -n [migration_name]
```

This will create a new subdirectory in the `migrations` directory of your project (created for you if it does not exist) with two files: `up.sql` and `down.sql`. 

The `up.sql` file is used to define the changes to be made to the database, and the `down.sql` file is used to define the changes to be made to revert the migration.

### Running Migrations

To run migrations, run the `migrate` command and supply either the `--url` flag with the URL of your Postgres database, or the `--env` flag to use a `.env` file with a `DATABASE_URL` entry.

```bash
dart run migrator migrate --url postgres://postgres:postgres@localhost:5432/postgres
```

OR

```bash
dart run migrator migrate --env
```

This will run any migrations that have not yet been run on the database.

### Rolling Back Migrations

**NOTE:** Rolling back migrations is not yet implemented, but is planned as such:

To roll back migrations, run the `rollback` command and supply the same flags as the `migrate` command.

```bash
dart run migrator rollback --url postgres://postgres:postgres@localhost:5432/postgres
```

OR

```bash
dart run migrator rollback --env
```

This will roll back the last migration that was run on the database.

## Configuration

**NOTE:** Configuration is not yet implemented, but is planned as such:

The `dart_migrator` package can be configured using a `migrator.yaml` file in the root of your project. The following options are available:

- `migrationsDirectory`: The directory where migrations are stored. Defaults to `migrations`.
- `migrationTable`: The name of the table used to store migration information. Defaults to `migrations`.
- `envFile`: The name of the `.env` file used to store environment variables. Defaults to `.env`.

Here is an example `migrator.yaml` file:

```yaml
migrationsDirectory: migrations
migrationTable: migrations
envFile: .env
```

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
