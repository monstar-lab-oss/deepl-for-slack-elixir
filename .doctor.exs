%Doctor.Config{
  exception_moduledoc_required: true,
  failed: false,
  ignore_modules: [
    DeepThought.Application,
    DeepThought.Repo,
    DeepThoughtWeb,
    DeepThoughtWeb.Endpoint,
    DeepThoughtWeb.ErrorHelpers,
    DeepThoughtWeb.ErrorView,
    DeepThoughtWeb.LayoutView,
    DeepThoughtWeb.Router,
    DeepThoughtWeb.Telemetry,
    DeepThoughtWeb.UserSocket
  ],
  ignore_paths: [],
  min_module_doc_coverage: 100,
  min_module_spec_coverage: 100,
  min_overall_doc_coverage: 100,
  min_overall_spec_coverage: 100,
  moduledoc_required: true,
  raise: true,
  reporter: Doctor.Reporters.Full,
  struct_type_spec_required: true,
  umbrella: false
}
