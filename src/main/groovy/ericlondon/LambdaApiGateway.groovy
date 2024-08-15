package ericlondon

import com.amazonaws.regions.Regions
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.s3.AmazonS3
import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.xlson.groovycsv.CsvParser
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

class LambdaApiGateway {
  static AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(Regions.US_EAST_1).build()

  static HandlerResponse handler(data, Context context) {

    try {

      // debug logging
      context.logger.log "data: $data"
      // context.logger.log "context: $context"
      context.logger.log "data.body: ${data.body}"

      // fetch file from s3
      if (data.path =~ /(?i)^\/s3/) {
        return LambdaApiGateway.fetchFromS3(data.body, context)
      } else {
        return new HandlerResponse(
          statusCode:501,
          headers:[:],
          body:JsonOutput.toJson([message:"Not yet implemented"])
        )
      }

    } catch(Exception error) {
      return new HandlerResponse(
        statusCode:400,
        headers:[:],
        body:JsonOutput.toJson([message:error])
      )
    }

  }

  static HandlerResponse fetchFromS3(body, context) {

    // debug logging
    context.logger.log "body: ${body}"

    def jsonSlurper = new JsonSlurper()
    def bodyObject = jsonSlurper.parseText(body)
    String bucket = bodyObject.bucket
    String key = bodyObject.key

    // debug logging
    context.logger.log "bodyObject: ${bodyObject}"
    context.logger.log "bucket: ${bucket}"
    context.logger.log "key: ${key}"

    String fileContents = s3.getObjectAsString(bucket, key)

    // debug logging
    context.logger.log "fileContents: ${fileContents}"

    if (key =~ /(?i)\.csv/) {

      def csvData = new CsvParser().parseCsv(fileContents)
      def jsonData = csvData.collect { row ->
        def entry = [:]
        row.columns.each { column ->
          entry[column.key] = row[column.key]
        }
        entry
      }

      def jsonString = JsonOutput.toJson(jsonData)

      // debug logging
      context.logger.log "jsonString: ${jsonString}"

      return new HandlerResponse(
        statusCode:200,
        headers:[:],
        body:jsonString
      )

    } else {
      return new HandlerResponse(
        statusCode:501,
        headers:[:],
        body:JsonOutput.toJson([message:"Not yet implemented"])
      )
    }
  }

}
