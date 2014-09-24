require 'logger'
log = Logger.new(STDOUT)

if ARGV.length < 2
  log.warn('usage: ruby import_posts.rb <posts_dumpfile> <"develop" | "product">')
  exit
end

INPUT = ARGV[0]
OUTPUT = 'posts_data'
db_name = ''

if ARGV[1] == 'product'
  db_name = 'db_name_production'
else
  db_name = 'db_name_development'
end

# INSERT部のみ抜き出し
# =========================================================================================
#

buf = ""
sql = ""
INSERT = 'INSERT INTO `posts` VALUES '
time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

open(INPUT){ |f|
  while f.gets do
    # テーブル名をpostsに修正
    $_.gsub!(/timeline/, "posts")
    if $_.include?(INSERT)
      # updated_atカラムを付与
      $_.gsub!(%r!'\)!, "','#{time}')")
      buf << $_
    end
  end
}

sql << buf

# 改行整形
# =========================================================================================
#

buf = ""

sql.lines { |line|
  line.gsub!(/#{INSERT}/, "INSERT INTO `posts` VALUES \n")
  line.gsub!(%r{\),}, "),\n")
  line.gsub!(%r{\);}, "),")
  line.gsub!(/\\\"/, "") #MySQLで出力したエスケープをrubyでパースできるよう変換
  buf << line
}

if buf.length > 0
  open("#{OUTPUT}.sql", 'w') { |output| output.print(buf) }
end

# CSVに変換
# =========================================================================================
#

buf = ""

open("#{OUTPUT}.sql") { |f|
  while f.gets do
    next if $_.include?(INSERT)
    $_.slice!(0)
    $_.slice!(-3, 2)
    buf << $_
  end
}

if buf.length > 0
  open("#{OUTPUT}.csv", 'w') { |output| output.print(buf) }
end

# 10_000個ずつに分割
# =========================================================================================
#

buf = ""
count = 0
num = 0

open("#{OUTPUT}.sql") { |f|
  buf << INSERT << "\n"
  while f.gets do
    if $_.include?(INSERT)
      next
    else
      count += 1
    end

    $_.gsub!(%r{\);}, "),")
    buf << $_

    if count > 10000
      buf[-2] = ";"
      open("#{OUTPUT}.#{num.to_s}.sql", 'w') { |output| output.print(buf) }
      buf = ''
      buf << INSERT << "\n"
      num += 1
      count = 0
    end
  end
}

if buf.length > 0
  buf[-2] = ";"
  open("#{OUTPUT}.#{num.to_s}.sql", 'w') { |output| output.print(buf) }
end

# 作成されたsqlを実行
# =========================================================================================
#
(0..num).each do |i|
  system("mysql -u root #{db_name} < #{OUTPUT}.#{i}.sql")
end

# 作成されたファイルを削除
# =========================================================================================
#
system("rm #{OUTPUT}.sql")
log.info("deleted #{OUTPUT}.sql")

(0..num).each do |i|
  system("rm #{OUTPUT}.#{i}.sql")
  log.info("deleted #{OUTPUT}.#{i}.sql")
end

log.info('done.')
