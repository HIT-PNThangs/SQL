use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLBenhVien')
	drop database QLBenhVien
go

CREATE DATABASE QLBenhVien
GO

USE QLBenhVien
GO

CREATE TABLE BenhVien (
	MaBV CHAR(5) PRIMARY KEY, 
	TenBV NVARCHAR(30)
)
go

CREATE TABLE KhoaKham (
	MaKhoa CHAR(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30), 
	SoBenhNhan INT, 
	MaBV char(5) FOREIGN KEY(MaBV) REFERENCES BenhVien(MaBV)
)
go

CREATE TABLE BenhNhan (
	MaBN CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(30), 
	NgaySinh DATETIME, 
	GioiTinh NVARCHAR(20), 
	SoNgayNV INT, 
	MaKhoa CHAR(5) FOREIGN KEY(MaKhoa) REFERENCES KhoaKham(MaKhoa)
)
go

INSERT INTO BenhVien VALUES 
('BV01', N'Bệnh viện 1'),
('BV02', N'Bệnh viện 2'),
('BV03', N'Bệnh viện 3')
go

INSERT INTO KhoaKham VALUES
('K01', N'Khoa khám 1', 3, 'BV01'), 
('K02', N'Khoa khám 2', 4, 'BV01'),
('K03', N'Khoa khám 3', 120, 'BV03')
go

INSERT INTO BenhNhan VALUES 
('BN01', N'Bệnh nhân 1', '2020-09-16',  N'Nữ', 20, 'K01'),
('BN02', N'Bệnh nhân 2', '2020-08-16',  N'Nam', 10, 'K02'),
('BN03', N'Bệnh nhân 3', '2020-07-16',  N'Nữ', 21, 'K03'),
('BN04', N'Bệnh nhân 4', '2020-06-16',  N'Nam', 12, 'K02'),
('BN05', N'Bệnh nhân 5', '2020-05-16',  N'Nữ', 4, 'K03') 
go

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
go

-- tạo hàm đưa ra số bệnh nhân có giới tính do người dùng nhập vào của từng bệnh viện
-- gồm các thông tin: tên bệnh viện, tổng số bệnh nhân
create function cau2(@GioiTinh nvarchar(5))
returns @bang table(TenBV nvarchar(30), TongSoBN int)
as
	begin
		insert into @bang 
			select BenhVien.TenBV, COUNT(BenhNhan.MaBN)
			from BenhVien inner join KhoaKham on BenhVien.MaBV = KhoaKham.MaBV
						  inner join BenhNhan on BenhNhan.MaKhoa = KhoaKham.MaKhoa
			where GioiTinh = @GioiTinh
			group by KhoaKham.MaKhoa, TenBV

		return
	end
go

select * from cau2(N'Nữ')
go

-- tạo thủ tục in ra tổng số bệnh nhân của 1 khoa trong bệnh viện với tham số là tên khoa và tên bệnh viện.
-- nếu không có tên khoa hoặc tên bệnh viện thì hiển thị thông báo
create proc cau3(@TenKhoa nvarchar(30), @TenBV nvarchar(30))
as
	begin
		if(not exists(select * from BenhVien inner join KhoaKham on BenhVien.MaBV = KhoaKham.MaBV where TenKhoa = @TenKhoa and TenBV = @TenBV))
			begin
				print N'Không có ' + @TenKhoa + N' hoặc bệnh viện ' + @TenBV
				rollback transaction
			end
		else 
			begin
				select sum(SoBenhNhan) as N'Số bệnh nhân'
				from BenhVien inner join KhoaKham on BenhVien.MaBV = KhoaKham.MaBV
				where TenKhoa = @TenKhoa and TenBV = @TenBV
			end
	end
go

-- thực thi
EXEC cau3 N'Khoa khám 1', N'Bệnh viện 1'
go

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
go

-- tạo trigger để tự động tăng số bệnh nhân trong KhoaKham, mỗi khi thêm dữ liệu cho bảng bệnh nhân
-- nếu số bệnh nhân trong 1 khoa khám > 100 thì không cho thêm và đưa ra cảnh báo
create trigger cau4
on BenhNhan
for insert
as
	begin
		declare @SoBNTrongKhoa int
		set @SoBNTrongKhoa = (select SoBenhNhan from KhoaKham inner join inserted on KhoaKham.MaKhoa = inserted.MaKhoa)
		if(@SoBNTrongKhoa > 100)
			begin
				declare @TenKhoa nvarchar(30)
				set @TenKhoa = (select TenKhoa from inserted inner join KhoaKham on KhoaKham.MaKhoa = inserted.MaKhoa)

				declare @TenBV nvarchar(30)
				set @TenBV = (SELECT TenBV FROM BenhVien inner join KhoaKham on BenhVien.MaBV = KhoaKham.MaBV WHERE KhoaKham.TenKhoa = @tenKhoa)

				print N'Không thể thêm vào bệnh viện: ' + @tenBV + N' của khoa: ' + @tenKhoa
				rollback tran
			end
		else 
			begin
				update KhoaKham
				set SoBenhNhan = SoBenhNhan + 1
				where MaKhoa = (select MaKhoa from inserted)
			end
	end
go

--thực thi
--THÀNH CÔNG
SELECT * FROM BenhVien
SELECT * FROM KhoaKham
go

INSERT INTO BenhNhan VALUES 
('BN07', N'Bệnh nhân 6', '2020-05-16',  N'Nữ', 4, 'K02')
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
go

--THẤT BẠI
INSERT INTO BenhNhan VALUES 
('BN08', N'Bệnh nhân 7', '2020-05-16',  N'Nữ', 4, 'K03')
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
go