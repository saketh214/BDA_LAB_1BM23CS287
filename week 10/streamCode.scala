import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

val spark = SparkSession.builder
  .appName("TextCleaningStream")
  .master("local[*]")
  .getOrCreate()

import spark.implicits._

val lines = spark.readStream
  .format("socket")
  .option("host", "localhost")
  .option("port", 9999)
  .load()

val words = lines.as[String]

val stopWords = Seq("is","the","a","an","and","to")

val cleaned = words.map { line =>
  val lower = line.toLowerCase
  val noSpace = lower.trim.replaceAll("\\s+"," ")
  val noPunct = noSpace.replaceAll("[^a-zA-Z ]","")
  val filtered = noPunct.split(" ").filter(word => !stopWords.contains(word))

  val lemmatized = filtered.map {
    case w if w.endsWith("ing") => w.dropRight(3)
    case w if w.endsWith("ed") => w.dropRight(2)
    case w => w
  }

  lemmatized.mkString(" ")
}

val query = cleaned.writeStream
  .outputMode("append")
  .format("console")
  .start()

query.awaitTermination()