# 1. Maven tabanlı bir build aşaması
FROM maven:3.9.4-eclipse-temurin-17 AS builder

# 2. Çalışma dizini oluştur
WORKDIR /app

# 3. Proje dosyalarını konteynere kopyala
COPY pom.xml .
COPY src ./src

# 4. Maven ile projeyi build et
RUN mvn clean package -DskipTests

# 5. Daha hafif bir Java runtime kullanarak çalıştırılabilir imaj oluştur
FROM eclipse-temurin:17-jdk

# 6. Çalışma dizini
WORKDIR /app

# 7. Builder aşamasından JAR dosyasını kopyala
COPY --from=builder /app/target/demo-docker-pipeline-1.0-SNAPSHOT.jar app.jar

# 8. Çalıştırma komutu
CMD ["java", "-jar", "app.jar"]
