use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLSach2v')
	drop database QLSach2
go
	
CREATE DATABASE QLSach2
GO

USE QLSach2
GO

CREATE TABLE TacGia (
	MaTG CHAR(5) PRIMARY KEY, 
	TenTG NVARCHAR(30), 
	SoLuongCo INT
)
go

CREATE TABLE NhaXB (
	MaNXB CHAR(5) PRIMARY KEY, 
	TenNXB NVARCHAR(30), 
	SoLuongCo INT
)
go

CREATE TABLE Sach (
	MaSach CHAR(5) PRIMARY KEY, 
	TenSach NVARCHAR(30), 
	MaNXB CHAR(5), 
	MaTG CHAR(5), 
	NamXB INT, 
	SoLuong INT, 
	DonGia MONEY, 
	CONSTRAINT fk_nxb FOREIGN KEY (MaNXB) REFERENCES NhaXB(MaNXB),
	CONSTRAINT fk_tg FOREIGN KEY (MaTG) REFERENCES TacGia(MaTG)
)
go

INSERT INTO TacGia VALUES
('TG01', N'Nguyễn Đình Huân', 20),
('TG02', N'Nguyễn Đình Huân 2', 30),
('TG03', N'Nguyễn Đình Huân 3 ', 40)
go

INSERT INTO NhaXB VALUES
('NXB01', N'Nhi Đồng', 10),
('NXB02', N'Thiếu niên', 15),
('NXB03', N'Tin tức', 20)
go

INSERT INTO Sach VALUES
('S01', N'Sách 01', 'NXB01', 'TG01', 2020, 11, 20000),
('S02', N'Sách 02', 'NXB02', 'TG01', 2019, 10, 21000),
('S03', N'Sách 03', 'NXB02', 'TG02', 2018, 9, 22000),
('S04', N'Sách 04', 'NXB02', 'TG02', 2021, 8, 23000),
('S05', N'Sách 05', 'NXB03', 'TG03', 2020, 7, 24000)
go

SELECT * FROM TacGia
SELECT * FROM NhaXB
SELECT * FROM Sach
go

-- CÂU 2: CREATE PROC
create proc cau2 (@MaSach char(5), @TenSach nvarchar(30), @TenNXB nvarchar(30), @MaTG char(5), @NamXB int, @SoLuong int, @DonGia money)
as
	begin
		if(not exists(select * from NhaXB where TenNXB = @TenNXB))
			begin
				print N'Tên nhà xuất bản KHÔNG tồn tại'
				return
			end
		else 
			begin
				declare @MaNXB char(5)
				set @MaNXB = (select MaNXB from NhaXB where TenNXB = @TenNXB)

				insert into Sach values (@MaSach, @TenSach, @MaNXB, @MaTG, @NamXB, @SoLuong, @DonGia)
			end
	end
go

--không thành công
EXEC cau2 'S06', N'Sách 06', N'Nhi Đồng 1', 'TG01', 2021, 9, 100000
SELECT * FROM Sach
go

--thành công
EXEC cau2 'S06', N'Sách 06', N'Nhi Đồng', 'TG01', 2021, 9, 100000
SELECT * FROM Sach
go

--Câu 3: create fucntion
create function cau3(@TenTG nvarchar(30))
returns money
as
	begin
		declare @TongTien money
		set @TongTien = (select sum(SoLuong * DonGia) from Sach inner join TacGia on Sach.MaTG = TacGia.MaTG where TenTG = @TenTG)
		return @TongTien
	end
go

--Thực thi
SELECT dbo.cau3 (N'Nguyễn Đình Huân') AS N'Tổng tiền'
go

--Câu 4: CREATE TRIGGER
create trigger cau4
on Sach
for insert
as
	begin
		if(not exists (select * from inserted inner join NhaXB on NhaXB.MaNXB = inserted.MaNXB))
			begin
				print N'Mã NXB chưa có mặt trong bảng NXB'
				rollback tran
			end
		else 
			begin
				update NhaXB 
				set SoLuongCo = SoLuongCo + (select SoLuong from inserted)
				where MaNXB = (select MaNXB from inserted)
			end
	end
go

--KHÔNG THÀNH CÔNG
INSERT INTO Sach VALUES ('S07', N'Sách 07', 'NXB08', 'TG03', 2020, 7, 24000)
SELECT * FROM NhaXB
SELECT * FROM Sach
go

--THÀNH CÔNG
INSERT INTO Sach VALUES ('S07', N'Sách 07', 'NXB02', 'TG03', 2022, 7, 14000)
SELECT * FROM NhaXB
SELECT * FROM Sach
go