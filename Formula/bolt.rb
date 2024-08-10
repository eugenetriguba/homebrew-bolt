class Bolt < Formula
  desc "Lightweight and language-agnostic database migration tool"
  homepage "https://github.com/eugenetriguba/bolt"
  url "https://github.com/eugenetriguba/bolt/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "efa2164d33d4221853ef6ca3fe072fbec8e1d4dbcb4719882eb7583147a7fad3"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "-o", bin/"bolt", "cmd/bolt/bolt.go"
  end

  test do
    ENV["BOLT_DB_NAME"] = "test.db"
    ENV["BOLT_DB_DRIVER"] = "sqlite3"
    mkdir "migrations"
    (testpath/"migrations"/"20240101122412_my_first_migration.sql").write <<~EOS
      -- migrate:up
      CREATE TABLE users(id INT PRIMARY KEY);
      -- migrate:down
      DROP TABLE users;
    EOS

    system bin/"bolt", "up"
    up_status_output = shell_output("#{bin}/bolt status")
    assert_match "20240101122412", up_status_output
    assert_match "my_first_migration", up_status_output
    assert_match "X", up_status_output

    system bin/"bolt", "down"
    down_status_output = shell_output("#{bin}/bolt status")
    assert_match "20240101122412", down_status_output
    assert_match "my_first_migration", down_status_output
    refute_match "X", down_status_output

    rm "migrations/20240101122412_my_first_migration.sql"
    status_output = shell_output("#{bin}/bolt status")
    refute_match "20240101122412", status_output
    refute_match "my_first_migration", status_output
    refute_match "X", status_output
  end
end

