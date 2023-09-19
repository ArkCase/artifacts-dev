# ArkCase Developer Deployment

This image is meant to house ArkCase's deployment artifacts for a developer's test deployment. Specifically, it's meant to allow developers to rapidly build and test deployment images without requiring to go through the entire CI/CD pipeline to run a test scenario they may wish to run.

The image's design is such that there's a "files" directory which mirrors the final container's "/app/files" directory, such that anything you put in there will be mirrored on the final container.

Thus, a developer can deploy files locally, build the image, and use it for their own local deployment without having to worry about the rest of the image construction infrastructure or the CI/CD pipelines.

## How to build

For a simple deployment, where most artifacts are provided by the developer:

```bash
# Please note that "my-test-image" can really be any name you wish
# as long as it complies with Docker's image naming requirements
docker build -t my-test-image .
```

### Customized Deployments

If you wish to use a specific release of ArkCase, then:

```bash
docker build -t my-test-image --build-arg ARKCASE_VER="2023.01.09.hotfix.test.99" .
```

Please note that the above example assumes that `ARKCASE_VER` is a valid version of ArkCase that **is already available in Nexus**.

If you wish to use a specific version of _.arkcase_, then the build argument is `CONF_VER`. Note that by default, `CONF_VER` is set to the same value as `ARKCASE_VER`, due to how closely related the two are.

If you wish to use a specific *flavor* of ArkCase (i.e. FOIA or Core), then use `--build-arg ENV=${value}` where `${value}` is one of `foia`, or `core`. Support for more *flavors* of ArkCase will be added in the near future.

As an example, to build ArkCase 2023.01.05 for FOIA, but using _.arkcase_ from 2022.06.03, use the following command:

```bash
docker build -t my-hybrid-image --build-arg ARKCASE_VER=2023.01.05 --build-arg CONF_VER=2022.06.03 --build-arg EXT=foia
```

### Deploying your own files

The **_files_** directory contains a mirror of the source files directory within the final container. This is where the deployment code will pull artifacts from for final deployment. It has the following structure:

```
files
├── alfresco
├── arkcase
│   ├── conf
│   └── wars
├── minio
├── pentaho
│   ├── warehouse
│   └── reports
└── solr
```

Here's a brief rundown of each directory. Artifacts will generally be deployed to leaf directories, but there's no actual prohibition to including other files at other levels, except that they likely won't be used by the helm charts. Each container will look for its required artifacts in only a strict, select few locations. Deviating from this will simply cause those containers to fail during the deployment phase.

* files/alfresco

  Houses Alfresco artifacts which describe how to initialize the content stores (i.e. which site(s) to create, RM site structure, users to create and which permissions to grant, etc). _(final format TBD)_

* files/arkcase/conf

  Houses configuration files that will eventually be extracted, verbatim, and in alphabetical order, into the `~/.arkcase` directory.  The order is important since this allows control over what files may get overwritten during deployment.

* files/arkcase/wars

  Houses the WAR files (packaged) that will eventually be deployed into ArkCase's Tomcat instance. The WAR filenames must be the final name, and will be deployed to Tomcat's _**webapps**_ folder just like Tomcat would (i.e. extracted into a folder matching their basename)

* files/minio

  Houses the files that describe how the Minio (S3-_emulator_) server will be initialized (which buckets to create, what features to enable in them, etc.)

* files/pentaho/warehouse

  Houses the Data Warehousing files that will be run periodically, in order to populate the analytical reports (i.e. DOJ reports, Neo4j demo, Broward demo reports, etc.).

* files/pentaho/reports

  Houses the actual reports that will be deployed into Pentaho. Each file will be deployed directly into Pentaho as a report (Pentaho supports deploying Zip files containing multiple reports).

* files/solr

  Houses the files that will describe to Solr which configurations to deploy, and which core(s) to create.

As an example: if you wish to deploy your own WAR file, you'd copy the file as `files/arkcase/wars/arkcase.war` and then run the build as described above. If you don't mind using the original, OOTB _.arkcase_ contents, then that's all you need to do.

If you also want to use your own _.arkcase_, then zip it all up and deploy it as `files/arkcase/conf/00-conf.zip`.

## How to deploy

In order to have the K8s deployment make use of your new image, you'll need to give it a solid, symbolic name. For instance:

```bash
docker build -t test/ACS-1344:latest .
```

In this scenario, you would then reference the following YAML file during helm deployment:

```YAML
global:
  image:
    core:
      app:
        artifacts:
          # This pull policy ensures that no attempt is made to pull this image externally
          pullPolicy: Never
          registry: "test"
          repository: "ACS-1344"
          tag: "latest"
```

Then, when deploying using Helm, you would do something like this:

```bash
helm install arkcase arkcase/app -f my-file.yaml
```

This will cause your entire stack to be launched using this specific image for your tests.

## Other Notes

Naturally, over time, the DevOps team may provide faster and simpler methods to achieve these tasks, i.e. through scripts or improved image structures. You should also endeavor to learn more about containerization technology so you can assist in these optimization efforts. That way you can help tailor the deployment model closer to what **works** for you, vs. what others _think_ might work for you.
