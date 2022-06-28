use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLSach')
DROP DATABASE QLSach
GO

CREATE DATABASE QLSach
GO

USE QLSach 
GO

CREATE TABLE TacGia (
	MaTG CHAR(5) PRIMARY KEY, 
	TenTG NVARCHAR(30)
)
go

CREATE TABLE NhaXB (
	MaNXB CHAR(5) PRIMARY KEY,
	TenNXB NVARCHAR(30)
)
go

create table Sach(
	MaSach char(5) primary key, 
	TenSach nvarchar(30),
	SoLuong int,
	DonGia money,
	MaTG char(5),
	MaNXB char(5),
	constraint FR_TG foreign key (MaTG) references TacGia(MaTG),
	constraint FR_NXB foreign key (MaNXB) references NhaXB(MaNXB)
)
go

INSERT INTO TacGia VALUES
('TG01', N'Tác giả 1'),
('TG02', N'Tác giả 2'),
('TG03', N'Tác giả 3') 
go

INSERT INTO NhaXB VALUES
('NXB01', N'Nhà Xuất Bản 1'),
('NXB02', N'Nhà Xuất Bản 2'),
('NXB03', N'Nhà Xuất Bản 3')
go

INSERT INTO Sach VALUES
('S01', N'Sách 1', 21, 250000, 'TG01', 'NXB01'),
('S02', N'Sách 2', 22, 240000, 'TG01', 'NXB02'),
('S03', N'Sách 3', 23, 230000, 'TG01', 'NXB03'),
('S04', N'Sách 4', 24, 220000, 'TG02', 'NXB01'),
('S05', N'Sách 5', 25, 210000, 'TG03', 'NXB01')
go

SELECT * FROM TacGia
SELECT * FROM NhaXB
SELECT * FROM Sach
go

--Câu 2: CREATE FUNCTION
CREATE FUNCTION fn_cau2 (@tenNXB NVARCHAR(30), @tenTG NVARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @tong INT
	SET @tong = (
		SELECT SUM(SoLuong)
		FROM Sach INNER JOIN TacGia 
		ON Sach.MaTG = TacGia.MaTG
		INNER JOIN NhaXB
		ON Sach.MaNXB = NhaXB.MaNXB
		WHERE TenTG = @tenTG AND TenNXB = @tenNXB
		GROUP BY TenTG, TenNXB
	)
	RETURN @tong
END
go

--thực thi
SELECT dbo.fn_cau2 (N'Nhà Xuất Bản 1', N'Tác giả 1') AS N'Tổng sách'
go

--Câu 3: tạo proc
CREATE PROC p_cau3 (@tenNXB NVARCHAR(30), @kq INT OUTPUT)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM NhaXB WHERE TenNXB = @tenNXB))
		BEGIN
			PRINT N'kHÔNG CÓ NHÀ XUẤT BẢN NÀY'
			SET @kq = 0
			RETURN
		END	
	ELSE 
		BEGIN
			DECLARE @tongTien MONEY 
			SET @tongTien = (
				SELECT SUM(DonGia)
				FROM Sach INNER JOIN NhaXB 
				ON Sach.MaNXB = NhaXB.MaNXB
				WHERE TenNXB = @tenNXB
				GROUP BY TenNXB
			)
			PRINT N'Tổng tiền sách của nhà xuất bản ' + @tenNXB + N' là ' + CONVERT(CHAR(10), @tongTien)
			SET @kq = 1
		END
END
go

DECLARE @kq INT
EXEC p_cau3 N'Nhà Xuất Bản 1', @kq OUTPUT
SELECT @kq AS N'Kết quả'
go

--Câu 4: tạo trigger
CREATE TRIGGER tg_cau4
ON Sach
FOR INSERT
AS
BEGIN
	DECLARE @maTG CHAR(5) = (SELECT MaTG FROM inserted)
	DECLARE @maNXB CHAR(5) = (SELECT MaNXB FROM inserted)

	IF(NOT EXISTS(SELECT * FROM TacGia WHERE MaTG = @maTG))
		BEGIN 
			RAISERROR(N'Không có mã tác giả này', 16, 1)
			ROLLBACK TRAN
		END
	ELSE IF(NOT EXISTS(SELECT * FROM NhaXB WHERE MaNXB = @maNXB))
		BEGIN 
			RAISERROR(N'Không có mã nhà xuất bản này', 16, 1)
			ROLLBACK TRAN
		END
END
go

--THỰC THI
--thành công
INSERT INTO Sach VALUES ('S06', N'Sách 1', 21, 250000, 'TG02', 'NXB02')
SELECT * FROM Sach
go

--thất bại: mã tác giả không có
INSERT INTO Sach VALUES ('S07', N'Sách 1', 21, 250000, 'TG022', 'NXB02') 
SELECT * FROM Sach
go

--thất bại: mã nhà xuất bản không có
INSERT INTO Sach VALUES ('S07', N'Sách 1', 21, 250000, 'TG02', 'NXB06')
SELECT * FROM Sach
go
