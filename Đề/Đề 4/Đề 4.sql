use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLHang')
	drop database QLHang
go

CREATE DATABASE QLHang
GO

USE QLHang 
GO

CREATE TABLE Hang (
	Mahang CHAR(5) PRIMARY KEY, 
	TenHang NVARCHAR(30), 
	DVTinh NVARCHAR(30), 
	SLTon INT
)
go

CREATE TABLE HDBan (
	MaHD CHAR(5) PRIMARY KEY, 
	NgayBan DATE, 
	HoTenKhach NVARCHAR(30)
)
go

CREATE TABLE HangBan (
	MaHD CHAR(5), 
	MaHang CHAR(5), 
	DonGia MONEY, 
	SoLuong INT, 
	PRIMARY KEY(MaHD, MaHang), 
	CONSTRAINT pk_hang FOREIGN KEY(MaHang) REFERENCES Hang(MaHang),
	CONSTRAINT pk_hdBan FOREIGN KEY(MaHD) REFERENCES HDBan(MaHD) 
)
go

INSERT INTO Hang VALUES 
('H01', N'Hàng 1', N'Cái', 30), 
('H02', N'Hàng 2', N'Hộp', 40), 
('H03', N'Hàng 3', N'Cái', 50)
go

INSERT INTO HDBan VALUES
('HD01', '2021-03-02', N'Khách hàng 1'),
('HD02', '2020-06-02', N'Khách hàng 2'),
('HD03', '2021-03-01', N'Khách hàng 3')
go

INSERT INTO HangBan VALUES 
('HD01', 'H01', 50000, 100),
('HD01', 'H02', 150000, 200),
('HD01', 'H03', 250000, 300),
('HD02', 'H01', 350000, 400),
('HD03', 'H01', 450000, 500)
go

SELECT * FROM Hang
SELECT * FROM HDBan
SELECT * FROM HangBan
go

--Câu 2: CREATE FUNCTION
CREATE FUNCTION fn_cau2(@thang INT, @nam INT)
RETURNS @bang TABLE (MaHD CHAR(5), NgayBan DATE, TongTien MONEY)
AS
	BEGIN
		INSERT INTO @bang
		SELECT HDBan.MaHD, NgayBan, SUM(SoLuong * DonGia)  
		FROM HDBan INNER JOIN HangBan ON HDBan.MaHD = HangBan.MaHD
		WHERE MONTH(NgayBan) = @thang AND YEAR(NgayBan) = @nam
		GROUP BY HDBan.MaHD, NgayBan
		RETURN
	END
go
--thực thi
SELECT * FROM dbo.fn_cau2(03, 2021)
go

--câu 3: tạo proc
CREATE PROC p_cau3 @maHD CHAR(5), @tenHang NVARCHAR(30), @donGia MONEY, @soLuong INT, @kq INT OUTPUT
AS
BEGIN
	--ktra tên hàng có tồn lại hay không
	IF(NOT EXISTS(SELECT * FROM Hang WHERE TenHang = @tenHang))
		BEGIN
			PRINT N'Không có tên hàng này'
			SET @kq = 0
			RETURN
		END
	--ktra mã hóa đơn có tồn tại hay không
	IF(NOT EXISTS(SELECT * FROM HDBan WHERE MaHD = @maHD))
		BEGIN
			PRINT N'Không có hóa đơn này'
			SET @kq = 0
			RETURN
		END
	--bên dưới đây mặc định là 2 thứ trên đã tồn tại có thể thêm
	--LẤY MÃ HÀNG
	DECLARE @maHang CHAR(5) = (SELECT MaHang FROM Hang WHERE TenHang = @tenHang)
	INSERT INTO HangBan VALUES (@maHD, @maHang, @donGia, @soLuong)
	SET @kq = 1
END
go

--THỰC THI
--chèn thành công
DECLARE @kq INT
EXEC p_cau3 'HD02', 'Hàng 2', 550000, 600, @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM HangBan
go
--chèn thất bại: tên hàng không có
DECLARE @kq INT
EXEC p_cau3 'HD02', 'Huân Đẹp Trai', 550000, 600, @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM HangBan
go
--chèn thất bại: không có mã hóa đơn này
DECLARE @kq INT
EXEC p_cau3 'HD023', 'Hàng 2', 550000, 600, @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM HangBan
go

--Câu 4: tạo trigger
create trigger cau4
on HangBan
for update
as
	begin
		declare @SLMoi int
		set @SLMoi = (select SoLuong from inserted)
		
		declare @SLCu int
		set @SLCu = (select SoLuong from deleted)

		declare @SL int
		set @SL = @SLMoi - @SLCu

		declare @SLTon int
		set @SLTon = (select SLTon from Hang inner join inserted on Hang.Mahang = inserted.MaHang)

		if(@SL > @SLTon)
			begin
				raiserror(N'Không thể cập nhật vì số lượng tồn không đủ', 16, 1)
				rollback tran
			end
		else 
			begin
				update Hang
				set SLTon = SLTon - @SL
				where Mahang = (select Mahang from inserted)
			end
	end
go

--THỰC THI
--thành công
UPDATE HangBan 
SET SoLuong = 120
WHERE MaHD = 'HD01' AND MaHang = 'H01'

SELECT * FROM Hang
SELECT * FROM HangBan
go

--thất bại
UPDATE HangBan 
SET SoLuong = 150
WHERE MaHD = 'HD01' AND MaHang = 'H01'

SELECT * FROM Hang
SELECT * FROM HangBan
go