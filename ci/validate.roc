app [main!] { 
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    parse: "https://github.com/imclerran/roc-tinyparse/releases/download/v0.3.3/kKiVNqjpbgYFhE-aFB7FfxNmkXQiIo2f_mGUwUlZ3O0.tar.br",
    ansi: "https://github.com/lukewilliamboswell/roc-ansi/releases/download/0.8.0/RQlGWlkQEfxtkSYKl0nHNQaOFT0-Jh7NNFEX2IPXlec.tar.br",
}

import cli.Stdout
import ansi.ANSI exposing [color]
import parse.CSV exposing [csv_string]
import parse.Parse exposing [one_or_more, maybe, string, lhs, rhs, map, zip_3, whitespace, finalize]

import "../packages.csv" as packages_csv : Str
import "../platforms.csv" as platforms_csv : Str

main! = |_args|
    "Validating packages... " |> Stdout.write!?
    _ = parse_known_repos(packages_csv) ? |_| Exit(1, "Failed to parse packages.csv" |> color({ fg: Standard Red }))
    "Ok" |> color({ fg: Standard Green }) |> Stdout.line!?
    "Validating platforms... " |> Stdout.write!?
    _ = parse_known_repos(platforms_csv) ? |_| Exit(1, "Failed to parse platforms.csv" |> color({ fg: Standard Red }))
    "Ok" |> color({ fg: Standard Green }) |> Stdout.line!


parse_known_repos = |csv_text|
    parser = parse_known_repos_header |> rhs(one_or_more(parse_known_repos_line)) |> lhs(maybe(whitespace))
    parser(csv_text) |> finalize |> Result.map_err(|_| BadKnownReposCSV)

parse_known_repos_header = |line|
    parser = maybe(string("repo,alias,remote") |> lhs(maybe(string(",")) |> lhs(string("\n"))))
    parser(line) |> Result.map_err(|_| MaybeShouldNotFail)

parse_known_repos_line = |line|
    pattern =
        zip_3(
            csv_string |> lhs(string(",")),
            csv_string |> lhs(string(",")),
            string("github") |> lhs(maybe(string(","))),
        )
        |> lhs(maybe(string("\n")))
    parser = pattern |> map(|(repo, alias, _remote)| Ok({ repo, alias }))
    parser(line) |> Result.map_err(|_| KnownReposLineNotFound)
