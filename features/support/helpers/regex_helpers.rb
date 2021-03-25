module RegexHelpers
  UUID_PATTERN = /\A[[:xdigit:]]{8}-(?:[[:xdigit:]]{4}-){3}[[:xdigit:]]{12}\Z/.freeze
end
