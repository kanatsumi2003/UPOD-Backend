# Stage 1: Build the solution
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["UPOD.API/UPOD.API.csproj", "UPOD.API/"]
COPY ["UPOD.REPOSITORIES/UPOD.REPOSITORIES.csproj", "UPOD.REPOSITORIES/"]
COPY ["UPOD.SERVICES/UPOD.SERVICES.csproj", "UPOD.SERVICES/"]

RUN dotnet restore "UPOD.API/UPOD.API.csproj"
COPY . .

WORKDIR /src/UPOD.API
RUN dotnet build "UPOD.API.csproj" -c Release -o /app/build

# Stage 2: Publish the API project
FROM build AS publish
RUN dotnet publish "UPOD.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Create the final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
EXPOSE 8221
EXPOSE 443

COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "UPOD.API.dll"]