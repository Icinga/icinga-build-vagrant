node default {
  hiera_include('classes', [])

  # TODO: replace functionality with profiles
  # this mimics the behavior of the customer2 module
  ensure_packages(hiera_array('packages', []))
  # ensure_resources('package', hiera_hash('package', {}))
  create_resources('apt::source', hiera_hash('apt::source', {}))
}