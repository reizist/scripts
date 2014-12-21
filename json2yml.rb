require 'json'
require 'yaml'

def merge_yaml(yaml1, yaml2)
  yaml2.each do |key, value|
    if value.class == Hash && yaml1.key?(key)
      yaml1[key] = merge_yaml(yaml1[key], value)
    else
      yaml1[key] = value
    end
  end
  yaml1
end

def make_union_yaml(dir)
  merged_yaml = {}
  Dir.glob("#{dir}/*.yml").each do |file|
    yaml = YAML.load_file(file)
    merged_yaml = merge_yaml(merged_yaml, yaml)
  end

  merged_yaml.to_yaml
end

def json2yml(json)
  JSON.parse(json).to_yaml
end

def yml2json(yml)
  YAML::load(yml).to_json
end

puts yml2json(make_union_yaml("#{Dir.pwd}/yml"))
