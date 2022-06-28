use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLNhapXuat')
	drop database QLNhapXuat
go

CREATE DATABASE	QLNhapXuat
GO

USE QLNhapXuat
GO

CREATE TABLE SANPHAM (
	MaSP CHAR(5) PRIMARY KEY, 
	TenSP NVARCHAR(30) NOT NULL, 
	MauSac NVARCHAR(30) NOT NULL, 
	SoLuong INT NOT NULL, 
	GiaBan MONEY NOT NULL
)
go

CREATE TABLE Nhap (
	SoHDN CHAR(5) PRIMARY KEY, 
	MaSP CHAR(5),
	SoLuongN INT NOT NULL, 
	NgayN DATE NOT NULL, 
	CONSTRAINT fk_nhap_sanPham FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
)
go

CREATE TABLE Xuat (
	SoHDX CHAR (5) PRIMARY KEY, 
	MaSP CHAR(5), 
	SoLuongX INT NOT NULL, 
	NgayX DATE NOT NULL, 
	CONSTRAINT fk_XUAT_sanPham FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
)
go

INSERT INTO SANPHAM VALUES 
('SP01', N'Sản phẩm 1', N'Đỏ', 10, 20000),
('SP02', N'Sản phẩm 2', N'Xanh', 20, 30000),
('SP03', N'Sản phẩm 3', N'Tím', 30, 40000)
go

INSERT INTO Nhap VALUES
('N01', 'SP01', 15, '2021-01-01'), 
('N02', 'SP01', 16, '2020-01-01'), 
('N03', 'SP02', 17, '2019-01-01')
go

INSERT INTO Xuat VALUES
('X01', 'SP01', 18, '2019-02-01'),
('X02', 'SP02', 19, '2019-02-02')
go

--thực thi
SELECT * FROM SANPHAM
SELECT * FROM Nhap
SELECT * FROM Xuat
go

-- Câu 2:
CREATE FUNCTION Cau2(@tenSP NVARCHAR(30))
RETURNS MONEY
AS
BEGIN
	DECLARE @tongTien MONEY 
	set @tongTien = (
		SELECT SUM(SoLuongN * GiaBan)
		FROM Nhap INNER JOIN SANPHAM
		ON Nhap.MaSP = SANPHAM.MaSP
		WHERE TenSP = @tenSP
	)
	RETURN @tongTien
END
go

--thực thi
SELECT dbo.Cau2 (N'Sản phẩm 1') AS N'Tổng tiền'
go

--Câu 3:
GO
CREATE PROC p_cau3 (@maSP CHAR(5), @tenSP NVARCHAR(30), @mauSac NVARCHAR(30),  @soLuong INT, 
					@giaBan MONEY, @kq INT OUTPUT)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM SANPHAM WHERE MaSP = @maSP))
		BEGIN
			SET @kq = 0
			INSERT INTO SANPHAM VALUES(@maSP, @tenSP, @mauSac, @soLuong, @giaBan)
		END
	ELSE 
			SET @kq = 1

	return @kq
END

--thực thi
--không insert đc
DECLARE @kq INT
EXEC p_cau3 'SP01', N'Sản phẩm 1', N'Đỏ', 10, 20000, @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM SANPHAM

--insert đc
DECLARE @kq INT
EXEC p_cau3 'SP04', N'Sản phẩm 4', N'Đỏ', 12, 120000, @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM SANPHAM

--Câu 4:
GO
alter TRIGGER tg_cau4
ON Xuat 
FOR INSERT
AS
BEGIN
	DECLARE @slX INT = (SELECT SoLuongX FROM inserted)
	DECLARE @sl INT = (SELECT SoLuong FROM SANPHAM INNER JOIN inserted ON SANPHAM.MaSP = inserted.MaSP)
	IF(@slX <= @sl)
		BEGIN
			UPDATE SANPHAM 
			SET SoLuong = SoLuong - @slX
			WHERE MaSP = (SELECT MaSP FROM inserted)
		END
	ELSE 
		BEGIN
			-- RAISERROR(N'Không đủ số lượng', 16, 1)]
			print N'Không đủ số lượng'
			ROLLBACK TRAN
		END
END
go

--THỰC THI
--INSERT KHÔNG THÀNH CÔNG
INSERT INTO Xuat VALUES ('X03', 'SP01', 19, '2019-02-02')
SELECT * FROM SANPHAM
SELECT * FROM Xuat
go

--INSERT THÀNH CÔNG
INSERT INTO Xuat VALUES ('X03', 'SP01', 5, '2019-02-02')
SELECT * FROM SANPHAM
SELECT * FROM Xuat
go