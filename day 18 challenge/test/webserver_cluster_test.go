package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServerClusterIntegration(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/services/webserver_cluster",

		Vars: map[string]interface{}{
			"cluster_name":  fmt.Sprintf("test-cluster-%s", uniqueID),
			"instance_type": "t2.micro",
			"ami_id":        "ami-0c55b159cbfafe1f0",
			"min_size":      1,
			"max_size":      2,
			"environment":   "dev",
			"project_name":  fmt.Sprintf("test-project-%s", uniqueID),
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	instanceID := terraform.Output(t, terraformOptions, "instance_id")

	url := fmt.Sprintf("http://%s:80", instanceID)
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 10, time.Second*5)
}
